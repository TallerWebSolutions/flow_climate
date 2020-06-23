# frozen_string_literal: true

module Highchart
  class StrategicChartsAdapter < HighchartAdapter
    attr_reader :company, :active_projects_count_data, :sold_hours_in_month, :consumed_hours_per_month, :available_hours_per_period,
                :flow_pressure_per_month_data, :money_per_month_data, :expenses_per_month_data

    def initialize(company, teams, projects, demands, start_date, end_date, chart_period_interval)
      super(demands, start_date, end_date, chart_period_interval)

      @company = company
      @active_projects_count_data = []
      @sold_hours_in_month = []
      @consumed_hours_per_month = []
      @flow_pressure_per_month_data = []
      @money_per_month_data = []
      @expenses_per_month_data = []

      @available_hours_per_period = TeamService.instance.compute_available_hours_to_team(teams, start_date.to_date, end_date.to_date, @chart_period_interval).values

      assign_attributes(projects)
    end

    private

    def assign_attributes(projects)
      assign_active_projects_count_data(projects)
      build_hours_per_month_analysis(projects)
      assign_flow_pressure_per_month_data(projects)
      assign_money_per_month_data(projects)
      assign_expenses_per_month_data
    end

    def build_hours_per_month_analysis(projects)
      @x_axis.each do |date|
        start_of_period = TimeService.instance.start_of_period_for_date(date, @chart_period_interval)
        end_of_period = TimeService.instance.end_of_period_for_date(date, @chart_period_interval)
        @consumed_hours_per_month << projects.active_in_period(start_of_period, end_of_period).map { |project| project.consumed_hours_in_period(start_of_period, end_of_period) }.sum.to_f
        @sold_hours_in_month << projects.active_in_period(start_of_period, end_of_period).sum(&:hours_per_day).to_f * period_multiplier
      end
    end

    def assign_active_projects_count_data(projects)
      @x_axis.each do |date|
        @active_projects_count_data << projects.active_in_period(TimeService.instance.start_of_period_for_date(date, @chart_period_interval), TimeService.instance.end_of_period_for_date(date, @chart_period_interval)).count
      end
    end

    def assign_flow_pressure_per_month_data(projects)
      @x_axis.each do |date|
        @flow_pressure_per_month_data << projects.active_in_period(TimeService.instance.start_of_period_for_date(date, @chart_period_interval), TimeService.instance.end_of_period_for_date(date, @chart_period_interval)).sum(&:flow_pressure).to_f
      end
    end

    def assign_money_per_month_data(projects)
      @x_axis.each do |date|
        @money_per_month_data << projects.active_in_period(TimeService.instance.start_of_period_for_date(date, @chart_period_interval), TimeService.instance.end_of_period_for_date(date, @chart_period_interval)).sum(&:money_per_day).to_f * period_multiplier
      end
    end

    def assign_expenses_per_month_data
      last_expense = 0
      @x_axis.each do |date|
        expenses_in_month = @company.financial_informations.for_month(date).first&.expenses_total&.to_f || last_expense
        @expenses_per_month_data << expenses_in_month
        last_expense = expenses_in_month
      end
    end

    def period_multiplier
      return 1 if daily?
      return 7 if weekly?

      30
    end
  end
end
