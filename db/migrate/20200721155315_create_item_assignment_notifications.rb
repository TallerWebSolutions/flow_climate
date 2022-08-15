# frozen_string_literal: true

class CreateItemAssignmentNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :item_assignment_notifications do |t|
      t.integer :item_assignment_id, null: false

      t.timestamps
    end

    add_foreign_key :item_assignment_notifications, :item_assignments, column: :item_assignment_id

    add_index :item_assignment_notifications, :item_assignment_id, unique: true
  end
end
