# frozen_string_literal: true

require 'date'
class TimeService
  include Singleton

  def compute_working_hours_for_dates(start_date, end_date)
    return 0 if start_date.blank? || end_date.blank? || (end_date - start_date) <= 1.minute

    compute_working_hours(start_date, end_date)
    # puts "total_hours #{total_hours}"
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

  private

  def compute_dates(min_date, max_date, period_frame, end_of_period)
    array_of_dates = []
    while min_date <= max_date
      array_of_dates << min_date.to_date
      min_date = (min_date + period_frame).send(end_of_period)
    end

    array_of_dates
  end

  def count_day_hours(start_time, end_time)
    initial_time = start_time
    total_hours = 0
    while initial_time < end_time
      total_hours += 1 unless initial_time.saturday? || initial_time.sunday? || out_of_work_time?(initial_time)
      initial_time += 1.hour
    end
    return total_hours if total_hours <= 6

    6
  end

  def compute_working_hours(start_time, end_time)
    end_first_day = start_time.end_of_day
    start_last_day = end_time.beginning_of_day
    full_days = business_days_between(start_time.end_of_day + 1.second, end_time.beginning_of_day - 1.second)

    (full_days * 6) + count_day_hours(start_time, end_first_day) + count_day_hours(start_last_day, end_time) if full_days.positive?
    count_day_hours(start_time, end_time)
  end

  def business_days_between(date1, date2)
    business_days = 0
    date = date2
    while date > date1
      business_days += 1 unless date.saturday? or date.sunday?
      date -= 1.day
    end
    business_days
  end

  def out_of_work_time?(initial_time)
    initial_time.hour >= 20 || initial_time.hour <= 7
  end
end
