# frozen_string_literal: true

class CreatePlan < ActiveRecord::Migration[5.2]
  def change
    create_table :plans do |t|
      t.integer :plan_value
      t.integer :plan_type

      t.integer :max_number_of_downloads, null: false

      t.timestamps
    end

    create_table :user_plans do |t|
      t.integer :user_id, index: true, null: false
      t.integer :plan_id, index: true, null: false

      t.integer :plan_billing_period, default: 0, null: false

      t.datetime :start_at, null: false
      t.datetime :finish_at, null: false

      t.boolean :active, default: false, null: false

      t.timestamps
    end

    add_foreign_key :user_plans, :users, column: :user_id
    add_foreign_key :user_plans, :plans, column: :plan_id
  end
end
