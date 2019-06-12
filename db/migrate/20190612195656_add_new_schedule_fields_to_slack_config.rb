# frozen_string_literal: true

class AddNewScheduleFieldsToSlackConfig < ActiveRecord::Migration[5.2]
  def up
    change_table :slack_configurations, bulk: true do |t|
      t.integer :weekday_to_notify, default: 0, null: false
      t.integer :notification_minute, default: 0, null: false
    end
  end

  def down
    change_table :slack_configurations, bulk: true do |t|
      t.remove :weekday_to_notify
      t.remove :notification_minute
    end
  end
end
