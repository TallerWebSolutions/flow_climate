# frozen_string_literal: true

class ChangeMembershipHoursHistoryNull < ActiveRecord::Migration[7.1]
  def change
    change_table :membership_available_hours_histories, bulk: true do |t|
      t.change_null :available_hours, false
      t.change_null :change_date, false
    end
  end
end
