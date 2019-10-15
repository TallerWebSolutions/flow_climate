# frozen_string_literal: true

# == Schema Information
#
# Table name: customers
#
#  company_id     :integer          not null, indexed, indexed => [name]
#  created_at     :datetime         not null
#  id             :bigint(8)        not null, primary key
#  name           :string           not null, indexed => [company_id]
#  products_count :integer          default(0)
#  projects_count :integer          default(0)
#  updated_at     :datetime         not null
#
# Foreign Keys
#
#  fk_rails_ef51a916ef  (company_id => companies.id)
#

class Customer < ApplicationRecord
  include ProjectAggregator

  belongs_to :company, counter_cache: true
  has_many :products, dependent: :restrict_with_error
  has_and_belongs_to_many :projects, dependent: :restrict_with_error

  validates :company, :name, presence: true
  validates :name, uniqueness: { scope: :company, message: I18n.t('customer.name.uniqueness') }
end
