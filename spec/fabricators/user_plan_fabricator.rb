# frozen_string_literal: true

Fabricator(:user_plan) do
  user
  plan

  plan_billing_period { :monthly }

  start_at { 1.month.ago }
  finish_at { 1.year.from_now }
end
