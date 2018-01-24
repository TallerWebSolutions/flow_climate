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
  has_many :products, dependent: :restrict_with_error
  has_many :projects, dependent: :restrict_with_error

  validates :company, :name, presence: true

  delegate :count, to: :products, prefix: true
  delegate :count, to: :projects, prefix: true

  def active_projects
    projects.where(status: :executing)
  end

  def waiting_projects
    projects.where(status: :waiting)
  end

  def red_projects
    projects.select(&:red?)
  end

  def delivered_scope
    projects.sum(&:total_throughput)
  end

  def current_backlog
    projects.sum(&:current_backlog)
  end

  def avg_hours_per_demand
    return 0 if projects_count.zero?
    projects.sum(&:avg_hours_per_demand) / projects_count.to_f
  end

  def total_value
    projects.sum(&:value)
  end

  def remaining_money
    projects.sum(&:remaining_money)
  end

  def percentage_remaining_money
    (remaining_money / total_value) * 100
  end

  def total_gap
    projects.sum(&:total_gap)
  end

  def percentage_remaining_scope
    (total_gap.to_f / current_backlog.to_f) * 100
  end

  def total_flow_pressure
    projects.sum(&:flow_pressure)
  end
end
