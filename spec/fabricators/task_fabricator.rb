# frozen_string_literal: true

Fabricator(:task) do
  work_item_type
  demand
  title { 'foo' }
  created_date { Time.zone.now }
end
