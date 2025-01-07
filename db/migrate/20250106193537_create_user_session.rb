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
      t.string :password_digest, null: true
      t.string :email_address, null: true, index: true
    end

    User.find_each do |user|
      user.update(email_address: user.email)
    end

    change_column_null :users, :encrypted_password, true
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
      t.remove :password_digest
      t.remove :email_address
      t.string :encrypted_password, null: false
    end
  end
end
