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

    def compute_developer_effort
      return unless @membership.developer?

      efforts_by_month = []

      @population_dates.each do |date|
        item_assignments = @membership.item_assignments.where(assignment_for_role: true).where('item_assignments.start_time BETWEEN :bottom_limit_date AND :upper_limit_date', bottom_limit_date: date.beginning_of_month, upper_limit_date: date.end_of_month).sum(:item_assignment_effort)
        efforts_by_month << item_assignments.to_f
      end

      efforts_by_month
    end

    def average_pull_interval
      return unless @membership.developer?

      average_time_to_pull_by_month = []

      @population_dates.each do |date|
        item_assignments = @membership.item_assignments.where('item_assignments.start_time BETWEEN :bottom_limit_date AND :upper_limit_date', bottom_limit_date: date.beginning_of_month, upper_limit_date: date.end_of_month).order(:start_time)

        average_time_to_pull_by_month << if item_assignments.count.positive?
                                           ((item_assignments.sum(:pull_interval) / item_assignments.count.to_f) / 1.hour).to_f
                                         else
                                           0
                                         end
      end

      average_time_to_pull_by_month
    end

    def compute_effort_for_assignment(assignment)
      stages_to_work_on = membership.stages_to_work_on

      stages_to_compute_effort = (assignment.stages_during_assignment & stages_to_work_on)

      return 0 if stages_to_compute_effort.blank?

      efforts_in_assignment = []
      stages_to_compute_effort.each do |stage|
        efforts_in_assignment << sum_efforts_in_demand_transitions(assignment, stage)
      end

      efforts_in_assignment.flatten.sum
    end

    private

    def start_population_date
      [@demands.kept.finished.map(&:end_date).compact.min, 1.year.ago].compact.max
    end

    def end_population_date
      [@demands.kept.finished.map(&:end_date).max, Time.zone.today].compact.min
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
