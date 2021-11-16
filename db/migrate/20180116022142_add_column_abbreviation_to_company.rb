# frozen_string_literal: true

class AddColumnAbbreviationToCompany < ActiveRecord::Migration[5.1]
  def change
    add_column :companies, :abbreviation, :string, null: false
    add_index :companies, :abbreviation, unique: true
  end
end
