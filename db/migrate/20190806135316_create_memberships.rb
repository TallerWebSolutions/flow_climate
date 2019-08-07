# frozen_string_literal: true

class CreateMemberships < ActiveRecord::Migration[5.2]
  def up
    change_table :team_members, bulk: true do |t|
      t.integer :company_id, index: true
      t.change_default :billable, true
    end

    create_table :memberships do |t|
      t.integer :team_member_id, index: true, null: false
      t.integer :team_id, index: true, null: false

      t.integer :member_role, default: 0, null: false

      t.timestamps
    end

    add_foreign_key :memberships, :team_members, column: :team_member_id
    add_foreign_key :memberships, :teams, column: :team_id

    TeamMember.all.each do |member|
      Membership.create(team_id: member.team_id, team_member_id: member.id)
      member.update(name: "#{member.teams.first.name} | #{member.name}") unless member.valid?
      member.update(company_id: Team.find_by(id: member.team_id).company_id)
    end

    add_foreign_key :team_members, :companies, column: :company_id

    remove_column :team_members, :team_id

    change_column_null :team_members, :company_id, false

    add_index :memberships, %i[team_id team_member_id], unique: true
    add_index :team_members, %i[company_id name jira_account_id], unique: true
  end

  def down
    change_table :team_members, bulk: true do |t|
      t.integer :team_id
      t.remove :company_id
    end

    drop_table :memberships
  end
end
