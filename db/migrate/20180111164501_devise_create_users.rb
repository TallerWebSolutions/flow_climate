# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      ## Database authenticatable
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :encrypted_password, null: false

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.inet :current_sign_in_ip
      t.inet :last_sign_in_ip

      t.timestamps null: false

      t.boolean :admin, null: false, default: false
    end

    add_index :users, :email, unique: true
    add_index :users, :reset_password_token, unique: true
  end
end
