# frozen_string_literal: true

class CreateSlackConfigurations < ActiveRecord::Migration[5.2]
  def change
    create_table :slack_configurations do |t|
      t.integer :team_id, null: false, index: true
      t.string :room_webhook, null: false
      t.integer :notification_hour, null: false

      t.timestamps
    end

    add_foreign_key :slack_configurations, :teams, column: :team_id
  end
end
