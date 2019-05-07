# frozen_string_literal: true

module SlackNotifier
  CLIENT = Slack::Notifier.new(Figaro.env.slack_token)
end
