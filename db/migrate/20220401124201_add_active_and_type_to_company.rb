# frozen_string_literal: true

class AddActiveAndTypeToCompany < ActiveRecord::Migration[7.0]
  def change
    change_table :companies, bulk: true do |t|
      t.integer :company_type, null: false, default: 0
      t.boolean :active, null: false, default: true
    end
  end
end
