# frozen_string_literal: true

class AddRiskReviewToFlowImpact < ActiveRecord::Migration[6.0]
  def change
    add_column :flow_impacts, :risk_review_id, :integer, index: true

    add_foreign_key :flow_impacts, :risk_reviews, column: :risk_review_id
  end
end
