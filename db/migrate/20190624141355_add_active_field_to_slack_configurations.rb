# frozen_string_literal: true

class AddActiveFieldToSlackConfigurations < ActiveRecord::Migration[5.2]
  def change
    add_column :slack_configurations, :active, :boolean, default: true
  end
end
