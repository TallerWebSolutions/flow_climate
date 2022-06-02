# frozen_string_literal: true

Fabricator(:slack_configuration) do
  team
  notification_hour 10
  room_webhook { Faker::Internet.url }
  info_type { 0 }
end
