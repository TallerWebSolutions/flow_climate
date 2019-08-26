# frozen_string_literal: true

# == Schema Information
#
# Table name: risk_reviews
#
#  company_id              :integer          not null, indexed
#  created_at              :datetime         not null
#  id                      :bigint(8)        not null, primary key
#  lead_time_outlier_limit :decimal(, )      not null
#  meeting_date            :date             not null, indexed => [product_id]
#  product_id              :integer          not null, indexed => [meeting_date], indexed
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_risk_reviews_on_company_id                   (company_id)
#  index_risk_reviews_on_meeting_date_and_product_id  (meeting_date,product_id) UNIQUE
#  index_risk_reviews_on_product_id                   (product_id)
#
# Foreign Keys
#
#  fk_rails_0e13c6d551  (company_id => companies.id)
#  fk_rails_dd98df4301  (product_id => products.id)
#

class RiskReview < ApplicationRecord
  belongs_to :company
  belongs_to :product

  has_many :demands, dependent: :nullify
  has_many :demand_blocks, dependent: :nullify

  validates :company, :product, :lead_time_outlier_limit, :meeting_date, presence: true

  validates :product, uniqueness: { scope: :meeting_date, message: I18n.t('risk_review.attributes.validations.product_uniqueness') }

  delegate :name, to: :product, prefix: true
end
