# frozen_string_literal: true

class AddPercentageEffortBugsToProject < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :percentage_effort_to_bugs, :integer, default: 0, null: false
  end
end
