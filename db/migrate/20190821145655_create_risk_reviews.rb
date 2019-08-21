# frozen_string_literal: true

class CreateRiskReviews < ActiveRecord::Migration[5.2]
  def change
    create_table :risk_reviews do |t|
      t.integer :company_id, null: false, index: true
      t.integer :product_id, null: false, index: true
      t.integer :demand_blocks_ids, array: true
      t.integer :projects_ids, array: true
      t.integer :demands_ids_in_period, array: true

      t.date :start_date, null: false
      t.date :end_date, null: false

      t.date :meeting_date, null: false

      t.decimal :lead_time_outlier_limit, null: false
      t.integer :outlier_demands_id, array: true

      t.timestamps
    end

    add_foreign_key :risk_reviews, :companies, column: :company_id
    add_foreign_key :risk_reviews, :products, column: :product_id

    add_index :risk_reviews, %i[meeting_date product_id], unique: true
  end
end
