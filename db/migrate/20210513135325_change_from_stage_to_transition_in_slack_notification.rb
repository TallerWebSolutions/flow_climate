# frozen_string_literal: true

class ChangeFromStageToTransitionInSlackNotification < ActiveRecord::Migration[6.1]
  def up
    drop_table :demand_transition_notifications
    drop_table :item_assignment_notifications

    change_table :demand_transitions, bulk: true do |t|
      t.boolean :transition_notified, index: true, null: false, default: false
      t.integer :team_member_id, index: true, null: true
    end

    add_column :item_assignments, :assignment_notified, :boolean, default: false, null: false

    add_foreign_key :demand_transitions, :team_members, column: :team_member_id

    execute('UPDATE demand_transitions SET transition_notified = true')
  end

  def down
    create_table :demand_transition_notifications do |t|
      t.integer :stage_id
      t.integer :demand_id

      t.timestamps
    end

    create_table :item_assignment_notifications do |t|
      t.integer :item_assignment_id

      t.timestamps
    end

    change_table :demand_transitions, bulk: true do |t|
      t.remove :transition_notified
      t.remove :team_member_id
    end

    remove_column :item_assignments, :assignment_notified
  end
end
