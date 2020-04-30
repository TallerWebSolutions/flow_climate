# frozen_string_literal: true

class CreateUserInvites < ActiveRecord::Migration[6.0]
  def change
    create_table :user_invites do |t|
      t.integer :company_id, index: true, null: false
      t.integer :invite_status, index: true, null: false

      t.integer :invite_type, index: true, null: false
      t.integer :invite_object_id, index: true, null: false

      t.string :invite_email, index: true, null: false

      t.timestamps
    end

    add_foreign_key :user_invites, :companies, column: :company_id
  end
end
