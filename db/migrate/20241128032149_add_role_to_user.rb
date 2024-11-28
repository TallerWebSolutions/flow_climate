# frozen_string_literal: true

class AddRoleToUser < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :user_role, :integer, null: false, default: 0
  end
end
