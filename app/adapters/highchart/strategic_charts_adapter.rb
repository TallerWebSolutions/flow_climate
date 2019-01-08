# frozen_string_literal: true

module Highchart
  class StrategicChartsAdapter
    attr_reader :company, :array_of_months, :active_projects_count_data, :sold_hours_in_month, :consumed_hours_per_month, :available_hours_per_month,
                :flow_pressure_per_month_data, :money_per_month_data, :expenses_per_month_data

    def initialize(company, projects, total_available_hours)
      @company = company
      @array_of_months = []
      @active_projects_count_data = []
      @sold_hours_in_month = []
      @consumed_hours_per_month = []
      @available_hours_per_month = []
      @flow_pressure_per_month_data = []
      @money_per_month_data = []
      @expenses_per_month_data = []

      assign_attributes(projects, total_available_hours)
    end

    private

    def assign_attributes(projects, total_available_hours)
      assign_months_by_projects_dates(projects)
      assign_active_projects_count_data(projects)
      build_hours_per_month_analysis(projects, total_available_hours)
      assign_flow_pressure_per_month_data(projects)
      assign_money_per_month_data(projects)
      assign_expenses_per_month_data
    end

    def build_hours_per_month_analysis(projects, available_hours)
      @array_of_months.each do |date|
        @consumed_hours_per_month << ProjectsRepository.instance.hours_consumed_per_month(projects, date)&.to_f
        @sold_hours_in_month << ProjectsRepository.instance.active_projects_in_month(projects, date).sum(&:hours_per_month)
        @available_hours_per_month << available_hours
      end
    end

    def assign_active_projects_count_data(projects)
      @array_of_months.each do |date|
        @active_projects_count_data << ProjectsRepository.instance.active_projects_in_month(projects, date).count
      end
    end

    def assign_flow_pressure_per_month_data(projects)
      @array_of_months.each do |date|
        @flow_pressure_per_month_data << ProjectsRepository.instance.flow_pressure_to_month(projects, date)
      end
    end

    def assign_money_per_month_data(projects)
      @array_of_months.each do |date|
        @money_per_month_data << ProjectsRepository.instance.money_to_month(projects, date).to_f
      end
    end

    def assign_expenses_per_month_data
      last_expense = 0
      @array_of_months.each do |date|
        expenses_in_month = @company.financial_informations.for_month(date).first&.expenses_total&.to_f || last_expense
        @expenses_per_month_data << expenses_in_month
        last_expense = expenses_in_month
      end
    end

    def assign_months_by_projects_dates(projects)
      min_date = projects.running.minimum(:start_date)
      max_date = projects.running.maximum(:end_date)

      @array_of_months = TimeService.instance.months_between_of(min_date, max_date)
    end
  end
end
