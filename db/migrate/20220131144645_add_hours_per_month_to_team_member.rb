# frozen_string_literal: true

class AddHoursPerMonthToTeamMember < ActiveRecord::Migration[6.1]
  def change
    add_column :team_members, :hours_per_month, :integer, default: 0
  end
end
