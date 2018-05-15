# frozen_string_literal: true

class AddManualEffortBooleanToDemand < ActiveRecord::Migration[5.2]
  def change
    add_column :demands, :manual_effort, :boolean, default: false
  end
end
