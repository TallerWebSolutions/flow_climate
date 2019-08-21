# frozen_string_literal: true

Fabricator(:risk_review) do
  company
  product

  start_date 1.month.ago
  end_date 1.day.ago

  meeting_date Time.zone.today

  lead_time_outlier_limit 100
end
