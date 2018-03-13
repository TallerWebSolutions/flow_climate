# frozen_string_literal: true

Fabricator(:pipefy_team_config) do
  team
  member_type { %i[developer analyst designer customer].sample }
  integration_id { Faker::IDNumber.ssn_valid }
  username { Faker::Internet.user_name }
end
