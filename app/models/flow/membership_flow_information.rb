# frozen_string_literal: true

module Flow
  class MembershipFlowInformation < SystemFlowInformation
    attr_reader :membership, :projects, :population_dates

    def initialize(membership)
      super(membership.demands)
      @membership = membership
      @projects = membership.projects

      @population_dates = TimeService.instance.months_between_of(start_population_date, end_population_date)
    end

    def compute_developer_effort(bottom_limit)
      return unless @membership.developer?

      membership_start = @membership.start_date
      item_assignments_efforts = @membership.item_assignments.where(assignment_for_role: true).where('item_assignments.start_time BETWEEN :upper_limit_date AND :bottom_limit_date', upper_limit_date: membership_start.beginning_of_day, bottom_limit_date: bottom_limit.end_of_day).sum(:item_assignment_effort)
      item_assignments_efforts.to_f
    end

    def average_pull_interval(bottom_limit)
      average_time_to_pull = 0

      membership_start = @membership.start_date
      item_assignments = @membership.item_assignments.where('item_assignments.start_time BETWEEN :upper_limit_date AND :bottom_limit_date', upper_limit_date: membership_start.beginning_of_day, bottom_limit_date: bottom_limit.end_of_day).order(:start_time)

      average_time_to_pull = ((item_assignments.sum(:pull_interval) / item_assignments.count.to_f) / 1.hour).to_f if item_assignments.count.positive?
      average_time_to_pull
    end

    def compute_effort_for_assignment(assignment)
      efforts_in_assignment = []
      assignment.stages_during_assignment.each do |stage|
        efforts_in_assignment << sum_efforts_in_demand_transitions(assignment, stage)
      end

      efforts_in_assignment.flatten.sum
    end

    private

    def start_population_date
      [@demands.kept.finished_until_date(Time.zone.now).filter_map(&:end_date).min, 1.year.ago].compact.max
    end

    def end_population_date
      [@demands.kept.finished_until_date(Time.zone.now).map(&:end_date).max, Time.zone.today].compact.min
    end

    def sum_efforts_in_demand_transitions(assignment, effort_stage)
      effort_transitions = effort_stage.demand_transitions.where(demand: assignment.demand).order(:last_time_in)
      effort_for_transitions = []

      effort_transitions.each do |effort_transition|
        start_date = [effort_transition.last_time_in, assignment.start_time].compact.max
        end_date = [effort_transition.last_time_out, assignment.finish_time].compact.min

        effort_for_transitions << compute_effort_in_membership_transition(start_date, end_date, effort_transition)
      end

      effort_for_transitions
    end

    def compute_effort_in_membership_transition(start_date, end_date, effort_transition)
      blocks_for_transition = effort_transition.demand.demand_blocks.closed.for_date_interval(effort_transition.last_time_in, effort_transition.last_time_out)

      TimeService.instance.compute_working_hours_for_dates(start_date, end_date) - sum_blocks_working_time(blocks_for_transition, end_date, start_date)
    end

    def sum_blocks_working_time(blocks_for_transition, end_date, start_date)
      effort_in_blocks = []
      blocks_for_transition.each do |block|
        start_block = [start_date, block.block_time].compact.max
        end_block = [end_date, block.unblock_time].compact.min

        effort_in_blocks << TimeService.instance.compute_working_hours_for_dates(start_block, end_block)
      end

      effort_in_blocks.compact.sum
    end
  end
end
