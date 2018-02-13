# frozen_string_literal: true

class DemandService
  include Singleton

  def compute_effort_for_dates(commitment_date, end_date)
    return 0 if commitment_date.blank? || end_date.blank?
    return compute_less_than_one_day_effort(commitment_date, end_date) if commitment_date.to_date == end_date.to_date
    compute_more_than_one_day_effort(commitment_date, end_date)
  end

  private

  def compute_more_than_one_day_effort(commitment_date, end_date)
    start_date = commitment_date
    business_days = 0
    while start_date <= end_date
      business_days += 1 unless start_date.saturday? || start_date.sunday?
      start_date += 1.day
    end
    business_days * 8
  end

  def compute_less_than_one_day_effort(commitment_date, end_date)
    (end_date - commitment_date) / 1.hour
  end
end
