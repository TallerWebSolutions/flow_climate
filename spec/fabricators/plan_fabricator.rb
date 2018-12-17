# frozen_string_literal: true

Fabricator(:plan) do
  plan_type { :gold }
  plan_period { :monthly }
  max_number_of_downloads { 10 }
  plan_value { 20 }
  max_number_of_users 0
  extra_download_value 0
  max_days_in_history 0
  plan_details 'bla'
end
