# frozen_string_literal: true

class CreateAzureProductConfigs < ActiveRecord::Migration[6.1]
  def change
    create_table :azure_product_configs do |t|
      t.references :product, null: false, index: true
      t.references :azure_account, null: false, index: true

      t.timestamps
    end
  end
end
