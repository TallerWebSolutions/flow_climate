# frozen_string_literal: true

class DemandEffortService
  include Singleton

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/MethodLength
  def build_efforts_to_demand(demand)
    demand_effort_ids = []

    demand.demand_transitions.order(:last_time_in).each do |transition|
      next unless transition.stage_compute_effort_to_project?

      end_date_for_assignment = [transition.last_time_out, Time.zone.now, demand.discarded_at].compact.min

      assignments_in_dates = demand.item_assignments.for_dates(transition.last_time_in, end_date_for_assignment).order(:start_time)
      top_effort_assignment = assignments_in_dates.max_by { |assign_in_date| assign_in_date.working_hours_until(transition.last_time_in, transition.last_time_out) }

      assignments_in_dates.each do |assignment|
        start_day = [assignment.start_time.to_date, transition.last_time_in].max.to_date
        end_day = [assignment.finish_time, transition.last_time_out, demand.discarded_at, Time.zone.now].compact.min.to_date

        (start_day..end_day).map do |day_to_effort|
          demand_effort_ids << compute_and_save_effort(day_to_effort, assignment, top_effort_assignment, transition)
        end
      end
    end
    demand.demand_efforts.where.not(id: demand_effort_ids).map(&:destroy)

    return if demand.manual_effort?

    update_demand_effort_caches(demand)
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/MethodLength

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

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def compute_and_save_effort(day_to_effort, assignment, top_effort_assignment, transition)
    demand = assignment.demand
    start_time = [assignment.start_time, transition.last_time_in].compact.max
    # define as the beginning of charge windows
    effort_start_date = [start_time, start_time.change(hour: 8, minute: 0, second: 0)].max

    end_time = [assignment.finish_time, transition.last_time_out, demand.discarded_at, Time.zone.now].compact.min
    # define as the end of charge windows
    end_date = [end_time, end_time.change(hour: 20, minute: 0, second: 0)].min

    membership = assignment.membership
    return if membership.client?

    team = demand.team
    company = team.company
    flow_events = team.flow_events.day_off + company.flow_events.day_off

    days_off = flow_events.map { |event| (event.event_date..event.event_end_date).cover?(day_to_effort) }
    return if days_off.compact.uniq.include?(true)

    demand_effort = demand.demand_efforts.where(demand_transition: transition, item_assignment: assignment, start_time_to_computation: effort_start_date).first_or_initialize
    return unless demand_effort.automatic_update?

    hours_in_assignment = (end_date - effort_start_date) / 1.hour

    previous_efforts_to_day = demand
                              .demand_efforts
                              .joins(item_assignment: :membership)
                              .where(item_assignment: { membership: assignment.membership })
                              .for_day(day_to_effort)

    previous_efforts_to_day -= [demand_effort]

    previous_efforts_value_to_day = previous_efforts_to_day.sum(&:effort_value)

    demand_effort_in_transition = if previous_efforts_value_to_day >= 6
                                    0
                                  elsif hours_in_assignment > 6
                                    TimeService.instance.compute_working_hours_for_dates(effort_start_date, end_date)
                                  else
                                    hours_in_assignment
                                  end

    main_assignment = (assignment == top_effort_assignment) || !top_effort_assignment.pairing_assignment?(assignment)

    stage_percentage = transition.stage_percentage_to_project
    pairing_percentage = transition.stage_pairing_percentage_to_project

    management_percentage = transition.stage_management_percentage_to_project

    effort_total = demand_effort_in_transition * (1 + management_percentage) * stage_percentage
    effort_value_blocked_in_transition = compute_effort_blocked(demand, effort_start_date, end_date, management_percentage, stage_percentage)

    # if there were many blocks into the effort time, the algorithm will compute each one, creating sometimes a negative effort
    # here we remove the exceding blocked value, comparing with the computed effort
    # the real effort is the intersection between effort time and the time blocked into the effort time, no matter how many blocks are
    effort_real_blocked_in_transition = [effort_value_blocked_in_transition, effort_total].min

    unless main_assignment
      effort_total *= pairing_percentage
      effort_real_blocked_in_transition *= pairing_percentage
    end

    effort_without_blocks = effort_total - effort_real_blocked_in_transition

    demand_effort.update(effort_value: effort_without_blocks, effort_with_blocks: effort_total, total_blocked: effort_real_blocked_in_transition, stage_percentage: stage_percentage,
                         management_percentage: management_percentage, pairing_percentage: pairing_percentage, main_effort_in_transition: main_assignment,
                         start_time_to_computation: effort_start_date, finish_time_to_computation: end_date)

    demand_effort.id
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity

  def compute_effort_blocked(demand, effort_start_date, end_date, management_percentage, stage_percentage)
    effort_blocked_in_transition = effort_blocked_into_time(demand, effort_start_date, end_date)
    effort_blocked_in_transition * (1 + management_percentage) * stage_percentage
  end

  def effort_blocked_into_time(demand, start_date, end_date)
    demand_blocks_into_effort_time = demand.demand_blocks.active.for_date_interval(start_date, end_date)

    return 0 if demand_blocks_into_effort_time.blank?

    demand_blocks_into_effort_time.sum do |block|
      start_block = [block.block_time, start_date].max
      end_block = [block.unblock_time, end_date].compact.min

      TimeService.instance.compute_working_hours_for_dates(start_block, end_block)
    end
  end
end
