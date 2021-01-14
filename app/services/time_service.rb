# frozen_string_literal: true

class TimeService
  include Singleton

  def compute_working_hours_for_dates(start_date, end_date)
    return 0 if start_date.blank? || end_date.blank? || (end_date - start_date) <= 1.minute

    compute_working_hours(start_date, end_date)
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

  def compute_working_hours(start_time, end_time)
    initial_time = start_time
    total_hours = 0
    while initial_time < end_time
      total_hours += 1 unless initial_time.saturday? || initial_time.sunday?
      initial_time += 1.hour
    end
    return total_hours if total_hours <= 6

    working_hours_greather_than_a_day(total_hours)
  end

  def working_hours_greather_than_a_day(total_hours)
    qtd_days = total_hours.to_f / 24.0
    return 6 if qtd_days <= 1

    qtd_completed_days = qtd_days.to_i
    qtd_hours = qtd_days % qtd_completed_days
    hours_to_compute = (24 * qtd_hours).round
    hours_to_compute = 6 if hours_to_compute > 6

    (qtd_completed_days * 6) + hours_to_compute
  end
end
