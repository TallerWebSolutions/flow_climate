# frozen_string_literal: true

class AddApiTokenToCompany < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :api_token, :string

    add_index :companies, :api_token, unique: true

    Company.all.each.map(&:save)

    change_column_null :companies, :api_token, false
  end
end
