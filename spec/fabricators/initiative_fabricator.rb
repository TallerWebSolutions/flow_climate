# frozen_string_literal: true

Fabricator(:initiative) do
  company
  name { 'initiative' }
  start_date { 2.months.ago }
  end_date { 1.month.from_now }
end
