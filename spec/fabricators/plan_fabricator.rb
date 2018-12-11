# frozen_string_literal: true

Fabricator(:plan) do
  plan_type { :standard }
  max_number_of_downloads { 10 }
  plan_value { 20 }
end
