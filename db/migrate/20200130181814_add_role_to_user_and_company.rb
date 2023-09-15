# frozen_string_literal: true

class AddRoleToUserAndCompany < ActiveRecord::Migration[6.0]
  def change
    rename_table :companies_users, :user_company_roles

    change_table :user_company_roles, bulk: true do |t|
      t.integer :user_role, index: true, default: 0, null: false

      t.date :start_date
      t.date :end_date
    end

    add_index :user_company_roles, %i[user_id company_id], unique: true
  end
end
