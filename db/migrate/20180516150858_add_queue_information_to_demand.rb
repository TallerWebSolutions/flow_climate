# frozen_string_literal: true

class AddQueueInformationToDemand < ActiveRecord::Migration[5.2]
  def change
    add_column :demands, :total_queue_time, :integer, default: 0
    add_column :demands, :total_touch_time, :integer, default: 0
  end
end
