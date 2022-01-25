# frozen_string_literal: true

Fabricator(:task) do
  demand
  title { 'foo' }
  created_date { Time.zone.now }
end
