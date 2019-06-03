# frozen_string_literal: true

Fabricator(:stage) do
  company
  integration_id { Faker::IDNumber.valid }
  name { Faker::Name.first_name }
  stage_type { [0, 1, 2, 3, 4, 5, 6].sample }
  stage_stream 0
  integration_pipe_id 1
  order 1
end
