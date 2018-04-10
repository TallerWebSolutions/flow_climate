# frozen_string_literal: true

Fabricator(:integration_error) do
  integration_type { :pipefy }
  integration_error_text { Faker::Lorem.paragraph }
end
