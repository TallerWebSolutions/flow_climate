# frozen_string_literal: true

Fabricator(:risk_review) do
  company
  product

  meeting_date Time.zone.today

  lead_time_outlier_limit 100
end
