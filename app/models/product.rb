# frozen_string_literal: true

# == Schema Information
#
# Table name: products
#
#  id             :integer          not null, primary key
#  customer_id    :integer          not null
#  name           :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  projects_count :integer          default(0)
#
# Indexes
#
#  index_products_on_customer_id  (customer_id)
#
# Foreign Keys
#
#  fk_rails_...  (customer_id => customers.id)
#

class Product < ApplicationRecord
  include ProjectAggregator

  belongs_to :customer, counter_cache: true
  has_many :projects, dependent: :restrict_with_error

  validates :name, :customer, presence: true

  delegate :name, to: :customer, prefix: true

  def current_backlog
    projects.sum(&:current_backlog)
  end
end
