# frozen_string_literal: true

class TimeService
  include Singleton

  def compute_working_hours_for_dates(commitment_date, end_date)
    return 0 if commitment_date.blank? || end_date.blank?
    compute_working_hours(commitment_date, end_date)
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
