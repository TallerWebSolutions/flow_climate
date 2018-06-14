# frozen_string_literal: true

class AddHoursBasedPaymentToTeamMember < ActiveRecord::Migration[5.1]
  def change
    change_table :team_members, bulk: true do |t|
      t.decimal :hour_value, default: 0
      t.decimal :total_monthly_payment
    end

    TeamMember.all.each do |member|
      member.update(total_monthly_payment: member.monthly_payment + (member.hours_per_month * member.hour_value))
    end

    change_column_null :team_members, :total_monthly_payment, false
  end
end
