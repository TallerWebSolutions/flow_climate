# frozen_string_literal: true

class MoveHoursPerMonthFromTeamMemberToMembership < ActiveRecord::Migration[5.2]
  def up
    change_table :memberships, bulk: true do |t|
      t.integer :hours_per_month
      t.date :start_date
      t.date :end_date
    end

    Membership.find_each { |membership| membership.update(hours_per_month: membership.team_member.hours_per_month, start_date: membership.team_member.start_date, end_date: membership.team_member.end_date) }

    memberships_start_date_nil = Membership.where(start_date: nil)
    team_members_start_date_nil = memberships_start_date_nil.where(start_date: nil).map(&:team_member)

    memberships_start_date_nil.map(&:destroy)
    team_members_start_date_nil.map(&:destroy)

    remove_column :team_members, :hours_per_month, :integer

    remove_index :memberships, %i[team_id team_member_id]

    change_column_null :memberships, :start_date, false
  end

  def down
    add_index :memberships, %i[team_id team_member_id], unique: true

    add_column :team_members, :hours_per_month, :integer

    Membership.find_each { |membership| membership.team_member.update(hours_per_month: membership.hours_per_month) }

    change_table :memberships, bulk: true do |t|
      t.remove :hours_per_month
      t.remove :start_date
      t.remove :end_date
    end
  end
end
