# frozen_string_literal: true

class AddCountryToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :language, :string, null: false, default: 'pt-BR'
    add_column :devise_customers, :language, :string, null: false, default: 'pt-BR'
  end
end
