# frozen_string_literal: true

class CreateServiceDeliveryReviewActionItems < ActiveRecord::Migration[7.0]
  def change
    create_table :service_delivery_review_action_items do |t|
      t.integer :service_delivery_review_id, null: false
      t.integer :membership_id, index: true, null: false
      t.integer :action_type, index: true, null: false, default: 0
      t.string :description, null: false
      t.date :deadline, null: false
      t.date :done_date

      t.timestamps
    end

    add_index :service_delivery_review_action_items, :service_delivery_review_id, name: 'service_delivery_review_action_items_sdr_id'

    add_foreign_key :service_delivery_review_action_items, :service_delivery_reviews, column: :service_delivery_review_id
    add_foreign_key :service_delivery_review_action_items, :memberships, column: :membership_id
  end
end
