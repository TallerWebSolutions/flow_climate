# frozen_string_literal: true

# == Schema Information
#
# Table name: slack_configurations
#
#  active              :boolean          default(TRUE)
#  created_at          :datetime         not null
#  id                  :bigint(8)        not null, primary key
#  info_type           :integer          default("average_demand_cost"), not null, indexed => [team_id]
#  notification_hour   :integer          not null
#  notification_minute :integer          default(0), not null
#  room_webhook        :string           not null
#  team_id             :integer          not null, indexed => [info_type], indexed
#  updated_at          :datetime         not null
#  weekday_to_notify   :integer          default("all_weekdays"), not null
#
# Indexes
#
#  index_slack_configurations_on_info_type_and_team_id  (info_type,team_id) UNIQUE
#  index_slack_configurations_on_team_id                (team_id)
#
# Foreign Keys
#
#  fk_rails_52597683c1  (team_id => teams.id)
#

class SlackConfiguration < ApplicationRecord
  enum info_type: { average_demand_cost: 0, current_week_throughput: 1, last_week_delivered_demands_info: 2, demands_wip_info: 3, outdated_demands: 4, failure_load: 5 }
  enum weekday_to_notify: { all_weekdays: 0, monday: 1, tuesday: 2, wednesday: 3, thursday: 4, friday: 5 }

  belongs_to :team

  validates :team, :room_webhook, :notification_hour, :notification_minute, :weekday_to_notify, presence: true
  validates :info_type, uniqueness: { scope: :team, message: I18n.t('slack_configuration.info_type.uniqueness') }

  validate :valid_room_uri?

  scope :active_configurations, -> { where(active: true) }

  def toggle_active
    update(active: !active?)
  end

  private

  def valid_room_uri?
    room_webhook_url = begin
                         URI.parse(room_webhook)
                       rescue StandardError
                         false
                       end
    return if room_webhook_url.is_a?(URI::HTTP) || room_webhook_url.is_a?(URI::HTTPS)

    errors.add(:room_webhook, I18n.t('errors.messages.invalid'))
  end
end
