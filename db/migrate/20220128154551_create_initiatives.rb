# frozen_string_literal: true

class CreateInitiatives < ActiveRecord::Migration[6.1]
  def change
    create_table :initiatives do |t|
      t.integer :company_id, null: false, index: true
      t.string :name, null: false, index: true

      t.date :start_date, null: false
      t.date :end_date, null: false

      t.timestamps
    end
    add_foreign_key :initiatives, :companies, column: :company_id
    add_index :initiatives, %i[company_id name], unique: true

    add_column :projects, :initiative_id, :integer
    add_foreign_key :projects, :initiatives, column: :initiative_id
  end
end
