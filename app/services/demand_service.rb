# frozen_string_literal: true

class DemandService
  include Singleton

  def compute_effort_for_dates(commitment_date, end_date)
    return 0 if commitment_date.blank? || end_date.blank?
    compute_effort(commitment_date, end_date)
  end

  private

  def compute_effort(start_time, end_time)
    initial_time = start_time
    total_hours = 0
    while initial_time < end_time
      total_hours += 1 unless initial_time.saturday? || initial_time.sunday?
      initial_time += 1.hour
    end
    return total_hours if total_hours <= 8
    total_hours.to_f / 3
  end
end
