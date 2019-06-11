# frozen_string_literal: true

Fabricator(:slack_configuration) do
  team
  notification_hour 10
  room_webhook 'http://foo.com.br'
  info_type { [0, 1, 2].sample }
end
