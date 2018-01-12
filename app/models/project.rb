# frozen_string_literal: true

# == Schema Information
#
# Table name: projects
#
#  id            :integer          not null, primary key
#  customer_id   :integer          not null
#  name          :string           not null
#  status        :integer          not null
#  project_type  :integer          not null
#  start_date    :date             not null
#  end_date      :date             not null
#  value         :decimal(, )
#  qty_hours     :decimal(, )
#  hour_value    :decimal(, )
#  initial_scope :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_projects_on_customer_id  (customer_id)
#
# Foreign Keys
#
#  fk_rails_...  (customer_id => customers.id)
#

class Project < ApplicationRecord
  enum status: { waiting: 0, executing: 1, finished: 2, cancelled: 3 }
  enum project_type: { outsourcing: 0, consulting: 1, training: 2 }

  belongs_to :customer
  has_many :project_results, dependent: :restrict_with_error

  validates :name, :start_date, :end_date, :status, :initial_scope, presence: true

  delegate :name, to: :customer, prefix: true

  def total_days
    (end_date - start_date).to_i
  end

  def remaining_days
    (end_date - Time.zone.today).to_i
  end

  def consumed_hours
    project_results.sum(&:total_hours_consumed)
  end
end
