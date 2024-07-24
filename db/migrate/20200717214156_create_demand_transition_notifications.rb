# frozen_string_literal: true

class CreateDemandTransitionNotifications < ActiveRecord::Migration[6.0]
  # rubocop:disable Rails/BulkChangeTable
  def change
    create_table :demand_transition_notifications do |t|
      t.integer :demand_id, index: true, null: false
      t.integer :stage_id, index: true, null: false

      t.timestamps
    end

    add_foreign_key :demand_transition_notifications, :demands, column: :demand_id
    add_foreign_key :demand_transition_notifications, :stages, column: :stage_id

    add_index :demand_transition_notifications, %i[demand_id stage_id], name: 'idx_demand_transtions_notifications'

    change_column_null :slack_configurations, :notification_hour, true
    change_column_null :slack_configurations, :notification_minute, true
  end
  # rubocop:enable Rails/BulkChangeTable
end
