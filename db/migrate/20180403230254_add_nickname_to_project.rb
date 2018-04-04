# frozen_string_literal: true

class AddNicknameToProject < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :nickname, :string
    add_index :projects, %i[nickname customer_id], unique: true
  end
end
