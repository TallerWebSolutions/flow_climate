# frozen_string_literal: true

class CreateCustomers < ActiveRecord::Migration[5.1]
  def change
    create_table :customers do |t|
      t.integer :company_id, null: false, index: true
      t.string :name, null: false

      t.timestamps
    end

    add_foreign_key :customers, :companies, column: :company_id
  end
end
