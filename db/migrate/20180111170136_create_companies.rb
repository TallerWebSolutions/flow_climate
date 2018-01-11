# frozen_string_literal: true

class CreateCompanies < ActiveRecord::Migration[5.1]
  def change
    create_table :companies do |t|
      t.string :name, null: false

      t.timestamps
    end

    create_table :companies_users, id: false do |t|
      t.integer :user_id, index: true
      t.integer :company_id, index: true

      t.timestamps
    end

    add_foreign_key :companies_users, :users, column: :user_id
    add_foreign_key :companies_users, :companies, column: :company_id

    add_column :users, :last_company_id, :integer, null: true, index: true
    add_foreign_key :users, :companies, column: :last_company_id
  end
end
