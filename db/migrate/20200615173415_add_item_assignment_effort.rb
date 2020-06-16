# frozen_string_literal: true

class AddItemAssignmentEffort < ActiveRecord::Migration[6.0]
  def up
    change_table :item_assignments, bulk: true do |t|
      t.decimal :item_assignment_effort, default: 0, null: false
      t.boolean :assignment_for_role, default: false # maps if an assignment was in a stage related to the role of the team_member
      t.integer :membership_id, index: true
    end
    add_foreign_key :item_assignments, :memberships, column: :membership_id

    ItemAssignment.all.each do |item_assignment|
      membership = Membership.where(team_member: item_assignment.team_member, team: item_assignment.demand.team).first_or_initialize

      membership.update(start_date: Time.zone.today) unless membership.valid?

      membership.save!

      membership_id = membership.id
      item_assignment.update(membership_id: membership_id)
    end

    remove_column :item_assignments, :team_member_id, :integer

    change_column_null :item_assignments, :membership_id, false
  end

  def down
    add_column :item_assignments, :team_member_id, :integer

    change_table :item_assignments, bulk: true do |t|
      t.remove :item_assignment_effort
      t.remove :assignment_for_role
      t.remove :membership_id
    end
  end
end
