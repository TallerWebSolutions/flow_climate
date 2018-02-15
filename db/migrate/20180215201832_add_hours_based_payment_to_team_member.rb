# frozen_string_literal: true

class AddHoursBasedPaymentToTeamMember < ActiveRecord::Migration[5.1]
  def change
    add_column :team_members, :hour_value, :decimal, default: 0
    add_column :team_members, :total_monthly_payment, :decimal

    TeamMember.all.each do |member|
      member.update(total_monthly_payment: member.monthly_payment + (member.hours_per_month * member.hour_value))
    end

    change_column_null :team_members, :total_monthly_payment, false
  end
end
