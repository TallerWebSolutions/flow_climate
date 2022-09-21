# frozen_string_literal: true

# == Schema Information
#
# Table name: slack_configurations
#
#  id                          :bigint           not null, primary key
#  active                      :boolean          default(TRUE)
#  config_type                 :integer          default("team")
#  info_type                   :integer          default("average_demand_cost"), not null
#  notification_hour           :integer
#  notification_minute         :integer
#  room_webhook                :string           not null
#  stages_to_notify_transition :integer          is an Array
#  weekday_to_notify           :integer          default("all_weekdays"), not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  customer_id                 :integer
#  team_id                     :integer
#
# Indexes
#
#  index_slack_configurations_on_config_type  (config_type)
#  index_slack_configurations_on_customer_id  (customer_id)
#  index_slack_configurations_on_team_id      (team_id)
#  slack_configuration_unique                 (info_type,team_id,room_webhook)
#
# Foreign Keys
#
#  fk_rails_27c3678ff8  (customer_id => customers.id)
#  fk_rails_52597683c1  (team_id => teams.id)
#

class SlackConfiguration < ApplicationRecord
  enum info_type: { average_demand_cost: 0, current_week_throughput: 1, last_week_delivered_demands_info: 2, demands_wip_info: 3, outdated_demands: 4, failure_load: 5, demand_state_changed: 6, item_assigned: 7, demand_blocked: 8 }
  enum config_type: { team: 0, customer: 1 }
  enum weekday_to_notify: { all_weekdays: 0, monday: 1, tuesday: 2, wednesday: 3, thursday: 4, friday: 5 }

  belongs_to :team, optional: true
  belongs_to :customer, optional: true

  validates :room_webhook, :weekday_to_notify, presence: true
  validates :info_type, uniqueness: { scope: %i[team room_webhook], message: I18n.t('slack_configuration.info_type.uniqueness') }

  validate :valid_room_uri?

  scope :active_configurations, -> { where(active: true) }

  def toggle_active
    update(active: !active?)
  end

  def notify_stage?(stage)
    stages_to_notify_transition&.include?(stage.id)
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
