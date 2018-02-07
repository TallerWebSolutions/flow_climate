# frozen_string_literal: true

class StrategicReportData
  attr_reader :array_of_months, :active_projects_count_data, :total_hours_in_month

  def initialize(company)
    @array_of_months = []
    @active_projects_count_data = []
    @total_hours_in_month = []
    assign_months_by_projects_dates(company)
    assign_active_projects_count_data(company)
    assign_total_hours_per_month(company)
  end

  private

  def assign_total_hours_per_month(company)
    @array_of_months.each do |month_year|
      @total_hours_in_month << ProjectsRepository.instance.running_projects_in_month(company, Date.new(month_year[1], month_year[0], 1)).sum(&:hours_per_month)
    end
  end

  def assign_active_projects_count_data(company)
    @array_of_months.each do |month_year|
      @active_projects_count_data << ProjectsRepository.instance.running_projects_in_month(company, Date.new(month_year[1], month_year[0], 1)).count
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
