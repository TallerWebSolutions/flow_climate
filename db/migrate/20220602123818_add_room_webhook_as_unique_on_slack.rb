# frozen_string_literal: true

class AddRoomWebhookAsUniqueOnSlack < ActiveRecord::Migration[7.0]
  def change
    remove_index :slack_configurations, %i[info_type team_id]
    add_index :slack_configurations, %i[info_type team_id room_webhook], name: 'slack_configuration_unique'
  end
end
