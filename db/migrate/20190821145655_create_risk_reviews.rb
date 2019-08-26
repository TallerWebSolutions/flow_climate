# frozen_string_literal: true

class CreateRiskReviews < ActiveRecord::Migration[5.2]
  def change
    create_table :risk_reviews do |t|
      t.integer :company_id, null: false, index: true
      t.integer :product_id, null: false, index: true

      t.date :meeting_date, null: false

      t.decimal :lead_time_outlier_limit, null: false

      t.timestamps
    end

    add_foreign_key :risk_reviews, :companies, column: :company_id
    add_foreign_key :risk_reviews, :products, column: :product_id

    add_index :risk_reviews, %i[meeting_date product_id], unique: true

    add_column :demands, :risk_review_id, :integer, index: true
    add_foreign_key :demands, :risk_reviews, column: :risk_review_id

    add_column :demand_blocks, :risk_review_id, :integer, index: true
    add_foreign_key :demand_blocks, :risk_reviews, column: :risk_review_id
  end
end
