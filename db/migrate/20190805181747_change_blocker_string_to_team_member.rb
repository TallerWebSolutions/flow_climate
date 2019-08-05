# frozen_string_literal: true

class ChangeBlockerStringToTeamMember < ActiveRecord::Migration[5.2]
  def up
    change_table :demand_blocks, bulk: true do |t|
      t.integer :blocker_id, index: true
      t.integer :unblocker_id, index: true

      t.string :unblock_reason
    end

    add_foreign_key :demand_blocks, :team_members, column: :blocker_id
    add_foreign_key :demand_blocks, :team_members, column: :unblocker_id

    DemandBlock.all.each do |block|
      blocker_member = block.demand.company.team_members.where(name: block.blocker_username).first
      unblocker_member = block.demand.company.team_members.where(name: block.unblocker_username).first

      next if blocker_member.blank?

      block.update(blocker_id: blocker_member.id, unblocker_id: unblocker_member&.id)
    end

    DemandBlock.where('blocker_id IS NULL OR unblocker_id IS NULL').map(&:destroy)

    change_column_null :demand_blocks, :blocker_id, false

    change_column_null :team_members, :monthly_payment, true
    change_column_null :team_members, :hours_per_month, true

    add_index :team_members, %i[team_id name jira_account_id], unique: true

    change_table :demand_blocks, bulk: true do |t|
      t.remove :blocker_username
      t.remove :unblocker_username
    end
  end

  def down
    change_table :demand_blocks, bulk: true do |t|
      t.remove :blocker_id
      t.remove :unblocker_id

      t.remove :unblock_reason

      t.string :blocker_username
      t.string :unblocker_username
    end
  end
end
