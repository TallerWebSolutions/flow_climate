# frozen_string_literal: true

class CreateUserSession < ActiveRecord::Migration[8.0]
  def up
    drop_table :sessions

    create_table :sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end

    change_table :users, bulk: true do |t|
      t.rename :email, :email_address
      t.rename :encrypted_password, :password_digest
    end
  end

  def down
    drop_table :sessions

    create_table :sessions do |t|
      t.string :session_id, null: false
      t.text :data
      t.timestamps
    end

    add_index :sessions, :session_id, unique: true
    add_index :sessions, :updated_at

    change_table :users, bulk: true do |t|
      t.rename :email_address, :email
      t.rename :password_digest, :encrypted_password
    end
  end
end
