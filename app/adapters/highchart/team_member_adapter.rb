# frozen_string_literal: true

module Highchart
  class TeamMemberAdapter
    attr_reader :team_member, :x_axis_hours_per_project, :y_axis_hours_per_project

    def initialize(team_member)
      @team_member = team_member
      @end_date = [team_member.end_date, Time.zone.now].compact.min
      @start_date = [team_member.first_effort&.start_time_to_computation, team_member.start_date, @end_date - 12.months].compact.max

      @x_axis_hours_per_project = TimeService.instance.months_between_of(@start_date, @end_date)
      @y_axis_hours_per_project = []

      @projects_efforts = {}

      build_item_assignments_efforts
      build_projects_in_efforts
      build_member_projects_efforts_chart
    end

    private

    attr_reader :start_date, :end_date, :item_assignments_efforts, :projects_in_efforts, :projects_efforts

    ##
    # It captures the projects in the efforts found and add it to the private instance variable
    def build_projects_in_efforts
      @projects_in_efforts = @item_assignments_efforts.map { |assignment| assignment.demand.project }.uniq
    end

    ##
    # It builds the efforts in the team member's item assignments for the start and end date built in the initialize
    def build_item_assignments_efforts
      @item_assignments_efforts = DemandEffort.joins(item_assignment: { membership: :team_member })
                                              .joins(:demand)
                                              .where('demand_efforts.effort_value > 0')
                                              .where(memberships: { team_member: @team_member })
                                              .where('start_time_to_computation BETWEEN :start_date AND :end_date', start_date: @start_date, end_date: @end_date)
    end

    ##
    # It builds the attributes responsibles for the data arrangement to the hours per project chart
    def build_member_projects_efforts_chart
      @x_axis_hours_per_project.each do |date|
        start_period = date.beginning_of_month
        end_period = date.end_of_month

        item_assignments_efforts_in_period = @item_assignments_efforts.where('start_time_to_computation BETWEEN :start_date AND :end_date', start_date: start_period, end_date: end_period)
        projects_in_period = item_assignments_efforts_in_period.map { |assignment| assignment.demand.project }.uniq

        build_project_efforts(item_assignments_efforts_in_period, projects_in_period)
        normalize_projects_data(projects_in_period)
      end

      @projects_efforts.each { |key, values| @y_axis_hours_per_project << { name: key, data: values } }
    end

    ##
    # It builds the projects efforts hash based on the projects found in the period
    def build_project_efforts(item_assignments_efforts_in_period, projects_in_period)
      projects_in_period.each do |project_active|
        effort_value_sum = 0
        efforts_project_active = item_assignments_efforts_in_period.where(demand: { project: project_active })
        effort_value_sum = efforts_project_active.sum(&:effort_value) if efforts_project_active.present?

        project_with_effort = @projects_efforts[project_active.name]
        if project_with_effort.present?
          @projects_efforts[project_active.name] << effort_value_sum.to_f
        else
          @projects_efforts[project_active.name] = [effort_value_sum.to_f]
        end
      end
    end

    def normalize_projects_data(projects_in_period)
      projects_out_period = @projects_in_efforts.map(&:name) - projects_in_period.map(&:name)

      projects_out_period.each do |out_project_name|
        if @projects_efforts[out_project_name].present?
          @projects_efforts[out_project_name] << 0
        else
          @projects_efforts[out_project_name] = [0]
        end
      end
    end
  end
end
