# frozen_string_literal: true

class CreateServiceDeliveryReviews < ActiveRecord::Migration[6.0]
  def change
    create_table :service_delivery_reviews do |t|
      t.integer :company_id, null: false, index: true
      t.integer :product_id, null: false, index: true

      t.date :meeting_date, null: false

      t.decimal :lead_time_top_threshold, null: false
      t.decimal :lead_time_bottom_threshold, null: false

      t.decimal :quality_top_threshold, null: false
      t.decimal :quality_bottom_threshold, null: false

      t.integer :expedite_max_pull_time_sla, null: false
      t.decimal :delayed_expedite_top_threshold, null: false
      t.decimal :delayed_expedite_bottom_threshold, null: false

      t.timestamps
    end

    add_foreign_key :service_delivery_reviews, :companies, column: :company_id
    add_foreign_key :service_delivery_reviews, :products, column: :product_id

    add_index :service_delivery_reviews, %i[meeting_date product_id], unique: true

    add_column :demands, :service_delivery_review_id, :integer
    add_index :demands, :service_delivery_review_id
    add_foreign_key :demands, :service_delivery_reviews, column: :service_delivery_review_id
  end
end
