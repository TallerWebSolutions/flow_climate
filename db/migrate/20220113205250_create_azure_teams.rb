# frozen_string_literal: true

class CreateAzureTeams < ActiveRecord::Migration[6.1]
  def change
    create_table :azure_teams do |t|
      t.integer :azure_product_config_id, null: false, index: true

      t.string :team_id, null: false
      t.string :team_name, null: false

      t.timestamps
    end

    add_foreign_key :azure_teams, :azure_product_configs, column: :azure_product_config_id
  end
end
