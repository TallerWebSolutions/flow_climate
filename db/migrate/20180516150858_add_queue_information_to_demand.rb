# frozen_string_literal: true

class AddQueueInformationToDemand < ActiveRecord::Migration[5.2]
  def change
    change_table :demands, bulk: true do |t|
      t.integer :total_queue_time, default: 0
      t.integer :total_touch_time, default: 0
    end
  end
end
