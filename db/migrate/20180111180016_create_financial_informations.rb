# frozen_string_literal: true

class CreateFinancialInformations < ActiveRecord::Migration[5.1]
  def change
    create_table :financial_informations do |t|
      t.integer :company_id, null: false, index: true

      t.date :finances_date, null: false
      t.decimal :income_total, null: false
      t.decimal :expenses_total, null: false

      t.timestamps
    end

    add_foreign_key :financial_informations, :companies, column: :company_id, index: true
  end
end
