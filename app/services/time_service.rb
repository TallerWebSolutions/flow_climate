# frozen_string_literal: true

class TimeService
  include Singleton

  def compute_working_hours_for_dates(start_date, end_date, company)
    return 0 if start_date.blank? || end_date.blank? || (end_date - start_date) <= 1.minute || company.blank?

    compute_working_hours(start_date, end_date, company)
  end

  def days_between_of(start_date, end_date)
    return [] if start_date.blank? || end_date.blank?

    compute_dates(start_date.end_of_day, end_date.end_of_day, 1.day, :end_of_day)
  end

  def weeks_between_of(start_date, end_date)
    return [] if start_date.blank? || end_date.blank?

    min_date = start_date.end_of_week.to_date
    max_date = end_date.end_of_week.to_date

    compute_dates(min_date, max_date, 1.week, :end_of_week)
  end

  def months_between_of(start_date, end_date)
    return [] if start_date.blank? || end_date.blank?

    min_date = start_date.end_of_month.to_date
    max_date = end_date.end_of_month.to_date

    compute_dates(min_date, max_date, 1.month, :end_of_month)
  end

  def start_of_period_for_date(date, period = 'month')
    return date.beginning_of_day if period == 'day'
    return date.beginning_of_week if period == 'week'

    date.beginning_of_month
  end

  def end_of_period_for_date(date, period = 'month')
    return date.end_of_day if period == 'day'
    return date.end_of_week if period == 'week'

    date.end_of_month
  end

  def add_weeks_to_today(weeks)
    Time.zone.today + weeks.weeks
  end

  def beginning_of_semester(date = Time.zone.today)
    if date.month < 7
      Date.new(date.year, 1, 1).beginning_of_day
    else
      Date.new(date.year, 7, 1).beginning_of_day
    end
  end

  def business_days_between(start_date, end_date)
    counter = 0

    (start_date.to_date..end_date.to_date).each do |day|
      counter += 1 unless day.saturday? || day.sunday?
    end

    counter
  end

  private

  def compute_dates(min_date, max_date, period_frame, end_of_period)
    array_of_dates = []
    while min_date <= max_date
      array_of_dates << min_date.to_date
      min_date = (min_date + period_frame).send(end_of_period)
    end

    array_of_dates
  end

  def compute_working_hours(start_time, end_time, company)
    initial_time = start_time
    working_total_hours = 0
    days_count = 0
    working_hours_per_day = company.company_working_hours_configs.for_date(initial_time.to_date).first&.hours_per_day || 6

    while initial_time < end_time
      working_total_hours += 1 unless initial_time.saturday? || initial_time.sunday? || out_of_work_time?(initial_time)

      if working_total_hours == working_hours_per_day
        working_total_hours = 0
        days_count += 1
        initial_time += 1.day
        initial_time = Time.zone.local(initial_time.year, initial_time.month, initial_time.day, 7)
      end

      initial_time += 1.hour
    end

    return (days_count * working_hours_per_day) + working_total_hours if days_count.positive?

    working_total_hours
  end

  def out_of_work_time?(initial_time)
    initial_time.hour >= 20 || initial_time.hour <= 8
  end
end
