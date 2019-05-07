# frozen_string_literal: true

# == Schema Information
#
# Table name: slack_configurations
#
#  created_at        :datetime         not null
#  id                :bigint(8)        not null, primary key
#  notification_hour :integer          not null
#  room_webhook      :string           not null
#  team_id           :integer          not null, indexed
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_slack_configurations_on_team_id  (team_id)
#
# Foreign Keys
#
#  fk_rails_52597683c1  (team_id => teams.id)
#

class SlackConfiguration < ApplicationRecord
  belongs_to :team

  validates :team, :room_webhook, :notification_hour, presence: true
end
