# frozen_string_literal: true

class AddInfoTypeFieldToSlackConfigurations < ActiveRecord::Migration[5.2]
  def change
    add_column :slack_configurations, :info_type, :integer, default: 0, null: false
    add_index :slack_configurations, :info_type

    add_index :slack_configurations, %i[info_type team_id], unique: true
  end
end
