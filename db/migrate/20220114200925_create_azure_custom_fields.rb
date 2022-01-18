# frozen_string_literal: true

class CreateAzureCustomFields < ActiveRecord::Migration[6.1]
  def change
    create_table :azure_custom_fields do |t|
      t.integer :azure_account_id, null: false
      t.integer :custom_field_type, null: false, default: 0
      t.string :custom_field_name, null: false

      t.timestamps
    end

    add_foreign_key :azure_custom_fields, :azure_accounts, column: :azure_account_id
  end
end
