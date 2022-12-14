# frozen_string_literal: true

class RemoveManualEffortFromDemand < ActiveRecord::Migration[7.0]
  def change
    remove_column :demands, :manual_effort, :boolean
  end
end
