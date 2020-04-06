# frozen_string_literal: true

class CreateRiskReviewActionItems < ActiveRecord::Migration[6.0]
  def change
    create_table :risk_review_action_items do |t|
      t.integer :risk_review_id, index: true, null: false
      t.integer :membership_id, index: true, null: false

      t.datetime :created_date, null: false

      t.integer :action_type, index: true, null: false, default: 0

      t.string :description, null: false
      t.date :deadline, null: false

      t.date :done_date

      t.timestamps
    end

    add_foreign_key :risk_review_action_items, :risk_reviews, column: :risk_review_id
    add_foreign_key :risk_review_action_items, :memberships, column: :membership_id
  end
end
