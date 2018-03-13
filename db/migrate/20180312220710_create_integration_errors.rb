# frozen_string_literal: true

class CreateIntegrationErrors < ActiveRecord::Migration[5.1]
  def change
    create_table :integration_errors do |t|
      t.integer :company_id, null: false, index: true
      t.datetime :occured_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.integer :integration_type, null: false, index: true
      t.string :integration_error_text, null: false

      t.timestamps
    end

    add_foreign_key :integration_errors, :companies, column: :company_id
  end
end
