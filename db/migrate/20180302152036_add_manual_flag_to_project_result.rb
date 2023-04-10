# frozen_string_literal: true

class AddManualFlagToProjectResult < ActiveRecord::Migration[5.1]
  def change
    add_column :project_results, :manual_input, :boolean, default: false, null: false
  end
end
