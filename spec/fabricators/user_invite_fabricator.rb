# frozen_string_literal: true

Fabricator(:user_invite) do
  company
  invite_status { [0, 1, 2].sample }
  invite_type { [0, 1, 2, 3].sample }
  invite_object_id { [30, 10, 15, 20].sample }
  invite_email { Faker::Internet.email }
  invite_object_id { [1, 2, 3, 4].sample }
end
