# frozen_string_literal: true

class AddNotificationEmailPreferenceToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :email_notifications, :boolean, default: false, null: false
  end
end
