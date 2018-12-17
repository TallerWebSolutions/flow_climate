# frozen_string_literal: true

class CreatePlan < ActiveRecord::Migration[5.2]
  def change
    create_table :plans do |t|
      t.integer :plan_value, null: false
      t.integer :plan_type, null: false
      t.integer :plan_period, null: false

      t.string :plan_details, null: false

      t.integer :max_number_of_downloads, null: false
      t.integer :max_number_of_users, null: false
      t.integer :max_days_in_history, null: false

      t.decimal :extra_download_value, null: false

      t.timestamps
    end

    create_table :user_plans do |t|
      t.integer :user_id, index: true, null: false
      t.integer :plan_id, index: true, null: false

      t.integer :plan_billing_period, default: 0, null: false
      t.decimal :plan_value, default: 0, null: false

      t.datetime :start_at, null: false
      t.datetime :finish_at, null: false

      t.boolean :active, default: false, null: false
      t.boolean :paid, default: false, null: false

      t.timestamps
    end
    add_foreign_key :user_plans, :users, column: :user_id
    add_foreign_key :user_plans, :plans, column: :plan_id

    change_table :demand_data_processments do |t|
      t.integer :user_plan_id, null: false, index: true
    end
    add_foreign_key :demand_data_processments, :user_plans, column: :user_plan_id

    change_table :users do |t|
      t.decimal :user_money_credits, default: 0, null: false
    end
  end
end
