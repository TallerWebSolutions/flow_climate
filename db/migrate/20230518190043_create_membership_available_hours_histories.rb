# frozen_string_literal: true

class CreateMembershipAvailableHoursHistories < ActiveRecord::Migration[7.0]
  def change
    create_table :membership_available_hours_histories do |t|
      t.integer :membership_id, index: true, null: false
      t.integer :available_hours
      t.datetime :change_date

      t.timestamps
    end

    add_foreign_key :membership_available_hours_histories, :memberships, column: :membership_id
  end
end
