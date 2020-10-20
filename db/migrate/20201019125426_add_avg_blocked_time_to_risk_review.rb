# frozen_string_literal: true

class AddAvgBlockedTimeToRiskReview < ActiveRecord::Migration[6.0]
  def change
    change_table :risk_reviews, bulk: true do |t|
      t.decimal :weekly_avg_blocked_time, array: true
      t.decimal :monthly_avg_blocked_time, array: true
    end
  end
end
