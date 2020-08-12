# frozen-string-literal: true

class AddStagesToNotifyToSlackConfiguration < ActiveRecord::Migration[6.0]
  def change
    change_table :slack_configurations, bulk: true do |t|
      t.integer :stages_to_notify_transition, array: true
    end

    change_column_default :slack_configurations, :notification_minute, from: 0, to: nil
  end
end
