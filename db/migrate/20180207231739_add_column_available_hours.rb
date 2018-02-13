# frozen_string_literal: true

class AddColumnAvailableHours < ActiveRecord::Migration[5.1]
  def change
    add_column :project_results, :available_hours, :decimal, null: false
  end
end
