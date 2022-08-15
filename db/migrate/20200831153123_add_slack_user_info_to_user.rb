# frozen_string_literal: true

class AddSlackUserInfoToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :user_company_roles, :slack_user, :string
  end
end
