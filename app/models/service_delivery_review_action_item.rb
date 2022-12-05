# frozen_string_literal: true

# == Schema Information
#
# Table name: service_delivery_review_action_items
#
#  id                         :bigint           not null, primary key
#  action_type                :integer          default("cadences_change"), not null
#  deadline                   :date             not null
#  description                :string           not null
#  done_date                  :date
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  membership_id              :integer          not null
#  service_delivery_review_id :integer          not null
#
# Indexes
#
#  index_service_delivery_review_action_items_on_action_type    (action_type)
#  index_service_delivery_review_action_items_on_membership_id  (membership_id)
#  service_delivery_review_action_items_sdr_id                  (service_delivery_review_id)
#
# Foreign Keys
#
#  fk_rails_b7142151f8  (service_delivery_review_id => service_delivery_reviews.id)
#  fk_rails_bcb8a4f6b9  (membership_id => memberships.id)
#
class ServiceDeliveryReviewActionItem < ApplicationRecord
  enum action_type: { cadences_change: 0, internal_comunication_change: 1, training: 2 }

  belongs_to :service_delivery_review
  belongs_to :membership

  validates :action_type, :description, :deadline, presence: true

  delegate :product, to: :service_delivery_review
end
