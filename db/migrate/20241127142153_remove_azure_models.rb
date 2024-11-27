# frozen_string_literal: true

class RemoveAzureModels < ActiveRecord::Migration[8.0]
  def up
    drop_table :azure_projects do |t|
      t.references :azure_team, null: false, index: true
    end

    drop_table :azure_teams do |t|
      t.integer :azure_product_config, null: false, index: true
    end

    drop_table :azure_custom_fields do |t|
      t.references :azure_account, null: false, index: true
    end

    drop_table :azure_accounts do |t|
      t.references :company, null: false, index: true
    end

    drop_table :azure_product_configs do |t|
      t.references :product, null: false, index: true
    end
  end

  def down
    create_table :azure_projects do |t|
      t.references :azure_team, null: false, index: true
      t.timestamps
    end

    create_table :azure_teams do |t|
      t.integer :azure_product_config, null: false, index: true
      t.timestamps
    end

    create_table :azure_custom_fields do |t|
      t.references :azure_account, null: false, index: true
      t.timestamps
    end

    create_table :azure_accounts do |t|
      t.references :company, null: false, index: true
      t.timestamps
    end

    create_table :azure_product_configs do |t|
      t.references :product, null: false, index: true
      t.timestamps
    end
  end
end
