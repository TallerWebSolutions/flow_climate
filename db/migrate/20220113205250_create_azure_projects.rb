# frozen_string_literal: true

class CreateAzureProjects < ActiveRecord::Migration[6.1]
  def change
    create_table :azure_projects do |t|
      t.integer :azure_product_config_id, null: false, index: true

      t.string :project_id, null: false
      t.string :project_name, null: false

      t.timestamps
    end

    add_foreign_key :azure_projects, :azure_product_configs, column: :azure_product_config_id
  end
end
