# frozen_string_literal: true

class StrategicReportData
  attr_reader :array_of_months, :active_projects_count_data, :total_hours_in_month, :consumed_hours_per_month, :available_hours_per_month, :flow_pressure_per_month_data

  def initialize(company)
    @array_of_months = []
    @active_projects_count_data = []
    @total_hours_in_month = []
    @consumed_hours_per_month = []
    @available_hours_per_month = []
    @flow_pressure_per_month_data = []

    assign_months_by_projects_dates(company)
    assign_active_projects_count_data(company)
    assign_total_hours_per_month(company)
    assign_consumed_hours_per_month(company)
    assign_available_hours_per_month(company)
    assign_flow_pressure_per_month_data(company)
  end

  private

  def assign_consumed_hours_per_month(company)
    @array_of_months.each do |month_year|
      @consumed_hours_per_month << ProjectsRepository.instance.hours_consumed_per_month(company, Date.new(month_year[1], month_year[0], 1))
    end
  end

  def assign_available_hours_per_month(company)
    @array_of_months.each do
      @available_hours_per_month << company.total_available_hours
    end
  end

  def assign_total_hours_per_month(company)
    @array_of_months.each do |month_year|
      @total_hours_in_month << ProjectsRepository.instance.active_projects_in_month(company, Date.new(month_year[1], month_year[0], 1)).sum(&:hours_per_month)
    end
  end

  def assign_active_projects_count_data(company)
    @array_of_months.each do |month_year|
      @active_projects_count_data << ProjectsRepository.instance.active_projects_in_month(company, Date.new(month_year[1], month_year[0], 1)).count
    end
  end

  def assign_flow_pressure_per_month_data(company)
    @array_of_months.each do |month_year|
      @flow_pressure_per_month_data << ProjectsRepository.instance.flow_pressure_to_month(company, Date.new(month_year[1], month_year[0], 1))
    end
  end

  def assign_months_by_projects_dates(company)
    min_date = company.projects.running.minimum(:start_date)
    max_date = company.projects.running.maximum(:end_date)

    return if max_date.blank? || min_date.blank?

    while min_date <= max_date
      @array_of_months << [min_date.month, min_date.year]
      min_date += 1.month
    end
  end
end
