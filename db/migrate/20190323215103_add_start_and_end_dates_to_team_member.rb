# frozen_string_literal: true

class AddStartAndEndDatesToTeamMember < ActiveRecord::Migration[5.2]
  def up
    change_table :team_members, bulk: true do |t|
      t.date :start_date
      t.date :end_date

      t.remove :hour_value
      t.remove :total_monthly_payment
    end
  end

  def down
    change_table :team_members, bulk: true do |t|
      t.remove :start_date
      t.remove :end_date

      t.decimal :hour_value
      t.decimal :total_monthly_payment
    end
  end
end
