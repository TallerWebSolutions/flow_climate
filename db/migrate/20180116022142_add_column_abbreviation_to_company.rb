# frozen_string_literal: true

class AddColumnAbbreviationToCompany < ActiveRecord::Migration[5.1]
  def change
    add_column :companies, :abbreviation, :string, index: true, null: false
  end
end
