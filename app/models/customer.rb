# frozen_string_literal: true

# == Schema Information
#
# Table name: customers
#
#  id         :integer          not null, primary key
#  company_id :integer          not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
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
  belongs_to :company
  has_many :projects, dependent: :restrict_with_error

  validates :company, :name, presence: true
end
