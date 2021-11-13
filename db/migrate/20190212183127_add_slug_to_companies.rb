# frozen_string_literal: true

class AddSlugToCompanies < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :slug, :string
    add_index :companies, :slug, unique: true
  end
end
