# frozen_string_literal: true

# == Schema Information
#
# Table name: risk_review_action_items
#
#  id             :bigint           not null, primary key
#  action_type    :integer          default("technical_change"), not null
#  created_date   :date             not null
#  deadline       :date             not null
#  description    :string           not null
#  done_date      :date
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  membership_id  :integer          not null
#  risk_review_id :integer          not null
#
# Indexes
#
#  index_risk_review_action_items_on_action_type     (action_type)
#  index_risk_review_action_items_on_membership_id   (membership_id)
#  index_risk_review_action_items_on_risk_review_id  (risk_review_id)
#
# Foreign Keys
#
#  fk_rails_1c155aea3e  (risk_review_id => risk_reviews.id)
#  fk_rails_fdf17a6550  (membership_id => memberships.id)
#
class RiskReviewActionItem < ApplicationRecord
  enum :action_type, { technical_change: 0, permissions_update: 1, customer_alignment: 2, internal_process_change: 3, cadences_change: 4, internal_comunication_change: 5, training: 6, guidance: 7 }

  belongs_to :risk_review
  belongs_to :membership

  validates :created_date, :action_type, :description, :deadline, presence: true

  delegate :product, to: :risk_review
end
