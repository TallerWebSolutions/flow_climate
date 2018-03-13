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
      total_hours += 1 unless initial_time.saturday? || initial_time.sunday? || resting_hour?(initial_time)
      initial_time += 1.hour
    end
    return total_hours if total_hours <= 6
    total_hours.to_f / 3
  end

  def resting_hour?(initial_time)
    sleeping_time(initial_time) || lunch_time(initial_time)
  end

  def sleeping_time(initial_time)
    initial_time.hour < 11 && initial_time.hour > 20
  end

  def lunch_time(initial_time)
    initial_time.hour >= 13 && initial_time.hour < 14
  end
end
