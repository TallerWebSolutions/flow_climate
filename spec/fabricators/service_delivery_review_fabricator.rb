# frozen_string_literal: true

Fabricator(:service_delivery_review) do
  company
  product

  meeting_date { 3.days.from_now }

  delayed_expedite_bottom_threshold { 5 }
  delayed_expedite_top_threshold { 5 }

  expedite_max_pull_time_sla { 2.hours }

  lead_time_bottom_threshold { 5.hours }
  lead_time_top_threshold { 5.hours }

  quality_bottom_threshold { 0.1 }
  quality_top_threshold { 0.2 }
end
