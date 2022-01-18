# frozen_string_literal: true

class CreateAzureAccounts < ActiveRecord::Migration[6.1]
  def change
    create_table :azure_accounts do |t|
      t.references :company, null: false, index: true
      t.string :username, null: false
      t.string :encrypted_password, null: false
      t.string :azure_organization, null: false

      t.timestamps
    end
  end
end
