# frozen_string_literal: true

class DemandEffortService
  include Singleton

  LIMIT_EFFORT_WHEN_IT_HAS_DROPS = 8
  NORMAL_EFFORT_LIMIT = 6

  # rubocop:disable Metrics/AbcSize
  def build_efforts_to_demand(demand)
    demand_effort_ids = []

    demand.demand_transitions.order(:last_time_in).each do |transition|
      next unless transition.stage_compute_effort_to_project?

      end_date_for_assignment = [transition.last_time_out, Time.zone.now, demand.discarded_at].compact.min

      assignments_in_dates = demand.item_assignments.for_dates(transition.last_time_in, end_date_for_assignment).order(:start_time)
      top_effort_assignment = assignments_in_dates.max_by { |assign_in_date| assign_in_date.working_hours_until(transition.last_time_in, transition.last_time_out) }

      assignments_in_dates.each do |assignment|
        process_assignment(assignment, demand, demand_effort_ids, top_effort_assignment, transition)
      end
    end

    demand.demand_efforts.where.not(id: demand_effort_ids).map(&:destroy)
  end
  # rubocop:enable Metrics/AbcSize

  def update_demand_effort_caches(demand)
    effort_upstream = demand.demand_efforts.upstream_efforts.sum(&:effort_value)
    effort_downstream = demand.demand_efforts.downstream_efforts.sum(&:effort_value)
    effort_development = demand.demand_efforts.developer_efforts.sum(&:effort_value)
    effort_design = demand.demand_efforts.designer_efforts.sum(&:effort_value)
    effort_management = demand.demand_efforts.manager_efforts.sum(&:effort_value)

    demand.update(effort_upstream: effort_upstream,
                  effort_downstream: effort_downstream,
                  effort_development: effort_development,
                  effort_design: effort_design,
                  effort_management: effort_management)
  end

  private

  def process_assignment(assignment, demand, demand_effort_ids, top_effort_assignment, transition)
    start_time = define_start(assignment, transition)
    end_time = define_end(assignment, demand, transition)

    (start_time..end_time).map do |day_to_effort|
      next if weekend?(day_to_effort)

      demand_effort_ids << compute_and_save_effort(day_to_effort, assignment, top_effort_assignment, transition)
    end
  end

  def define_end(assignment, demand, transition)
    [assignment.finish_time, transition.last_time_out, demand.discarded_at, Time.zone.now].compact.min.to_date
  end

  def define_start(assignment, transition)
    [assignment.start_time.to_date, transition.last_time_in].max.to_date
  end

  def weekend?(day_to_effort)
    day_to_effort.saturday? || day_to_effort.sunday?
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def compute_and_save_effort(day_to_effort, assignment, top_effort_assignment, transition)
    demand = assignment.demand
    return if day_off?(day_to_effort, demand)

    membership = assignment.membership
    return if membership.client?

    start_time = [assignment.start_time, transition.last_time_in].compact.max

    effort_start_time = [start_time, day_to_effort.beginning_of_day.change(hour: 8, minute: 0, second: 0)].max
    effort_end_time = [assignment.finish_time, transition.last_time_out, demand.discarded_at, day_to_effort.end_of_day.change(hour: 20, minute: 0, second: 0), Time.zone.now].compact.min

    demand_effort = demand
                    .demand_efforts
                    .where(demand_transition: transition, item_assignment: assignment)
                    .where('start_time_to_computation BETWEEN :start_time AND :end_time',
                           start_time: effort_start_time.beginning_of_day,
                           end_time: start_time.end_of_day).first_or_initialize

    return demand_effort.id unless demand_effort.automatic_update?

    effort_by_dates = effort_by_dates(demand, demand_effort, effort_start_time, effort_end_time)

    main_assignment = (assignment == top_effort_assignment) || !top_effort_assignment.pairing_assignment?(assignment)

    stage_percentage = transition.stage_percentage_to_project
    pairing_percentage = transition.stage_pairing_percentage_to_project

    management_percentage = transition.stage_management_percentage_to_project

    effort_total = effort_by_dates * (management_percentage + 1) * stage_percentage

    effort_total *= pairing_percentage unless main_assignment

    effort_total = remove_member_previous_efforts_in_demand(assignment, demand, demand_effort, effort_start_time, effort_total)

    demand_effort.update(effort_value: effort_total, stage_percentage: stage_percentage,
                         management_percentage: management_percentage, pairing_percentage: pairing_percentage, main_effort_in_transition: main_assignment,
                         start_time_to_computation: effort_start_time, finish_time_to_computation: effort_end_time)

    demand_effort.id
  end

  def remove_member_previous_efforts_in_demand(assignment, demand, demand_effort, effort_start_time, effort_total)
    previous_efforts_to_day = demand
                              .demand_efforts
                              .joins(item_assignment: :membership)
                              .where(item_assignment: { membership: assignment.membership })
                              .previous_in_day(effort_start_time)

    previous_efforts_to_day -= [demand_effort]
    previous_efforts_value_to_day = previous_efforts_to_day.sum(&:effort_value)

    if previous_efforts_value_to_day >= LIMIT_EFFORT_WHEN_IT_HAS_DROPS
      [effort_total - previous_efforts_value_to_day, 0].max
    else
      effort_total
    end
  end

  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength
  def effort_by_dates(demand, demand_effort, effort_start_time, end_time)
    effort_in_minutes = 0
    blocked_effort_in_minutes = 0
    initial_time = effort_start_time
    while initial_time < end_time
      if blocked?(demand, initial_time)
        blocked_effort_in_minutes += 1
      else
        effort_in_minutes += 1
      end

      initial_time += 1.minute

      break if effort_in_minutes >= NORMAL_EFFORT_LIMIT * 60
    end

    effort_in_hours = effort_in_minutes.to_f / 60
    effort_blocked_in_hours = blocked_effort_in_minutes.to_f / 60
    demand_effort.total_blocked = effort_blocked_in_hours

    effort_in_hours
  end
  # rubocop:enable Metrics/MethodLength

  def day_off?(day_to_effort, demand)
    team = demand.team
    company = team.company
    flow_events = team.flow_events.day_off + company.flow_events.day_off
    days_off = flow_events.map { |event| (event.event_date..event.event_end_date).cover?(day_to_effort) }
    days_off.compact.uniq.include?(true)
  end

  def blocked?(demand, effort_time)
    blocks = demand.demand_blocks.where(':effort_time BETWEEN block_time AND unblock_time', effort_time: effort_time)

    return true if blocks.present?

    false
  end
end
