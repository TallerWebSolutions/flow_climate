# frozen_string_literal: true

# == Schema Information
#
# Table name: customers
#
#  id             :integer          not null, primary key
#  company_id     :integer          not null
#  name           :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  products_count :integer          default(0)
#  projects_count :integer          default(0)
#
# Indexes
#
#  index_customers_on_company_id  (company_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#

class Customer < ApplicationRecord
  include ProjectAggregator

  belongs_to :company, counter_cache: true
  has_many :products, dependent: :restrict_with_error
  has_many :projects, dependent: :restrict_with_error

  validates :company, :name, presence: true
end
