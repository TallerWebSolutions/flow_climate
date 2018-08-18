# frozen_string_literal: true

class TimeService
  include Singleton

  def compute_working_hours_for_dates(start_date, end_date)
    return 0 if start_date.blank? || end_date.blank?
    compute_working_hours(start_date, end_date)
  end

  def skip_weekends(date, increment)
    date += increment.round.days
    date += 1.day while (date.wday % 7).zero? || (date.wday % 7 == 6)
    date
  end

  def weeks_between_of(start_date, end_date)
    array_of_weeks = []

    return [] if start_date.blank? || end_date.blank?

    min_date = start_date

    while min_date <= end_date
      array_of_weeks << min_date.beginning_of_week
      min_date += 7.days
    end

    array_of_weeks
  end

  def months_between_of(start_date, end_date)
    array_of_months = []

    return [] if start_date.blank? || end_date.blank?

    min_date = start_date

    while min_date <= end_date
      array_of_months << Date.new(min_date.year, min_date.month, 1)
      min_date += 1.month
    end

    array_of_months
  end

  private

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
