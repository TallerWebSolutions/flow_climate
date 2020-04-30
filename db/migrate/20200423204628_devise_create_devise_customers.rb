# frozen_string_literal: true

class DeviseCreateDeviseCustomers < ActiveRecord::Migration[6.0]
  def change
    create_table :devise_customers do |t|
      ## Database authenticatable
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email,              null: false, default: ''
      t.string :encrypted_password, null: false, default: ''

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.inet     :current_sign_in_ip
      t.inet     :last_sign_in_ip

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at

      t.timestamps null: false
    end

    add_index :devise_customers, :email,                unique: true
    add_index :devise_customers, :reset_password_token, unique: true
    # add_index :devise_customers, :confirmation_token,   unique: true
    # add_index :devise_customers, :unlock_token,         unique: true

    create_table :customers_devise_customers do |t|
      t.integer :customer_id, index: true, null: false
      t.integer :devise_customer_id, index: true, null: false

      t.timestamps
    end

    add_foreign_key :customers_devise_customers, :customers, column: :customer_id
    add_foreign_key :customers_devise_customers, :devise_customers, column: :devise_customer_id
    add_index :customers_devise_customers, %i[customer_id devise_customer_id], unique: true, name: 'idx_customers_devise_customer_unique'
  end
end
