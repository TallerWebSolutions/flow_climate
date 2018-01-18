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
#  product_id    :integer
#
# Indexes
#
#  index_projects_on_customer_id  (customer_id)
#
# Foreign Keys
#
#  fk_rails_...  (customer_id => customers.id)
#  fk_rails_...  (product_id => products.id)
#

class Project < ApplicationRecord
  enum status: { waiting: 0, executing: 1, maintenance: 2, finished: 3, cancelled: 4 }
  enum project_type: { outsourcing: 0, consulting: 1, training: 2 }

  belongs_to :customer
  belongs_to :product
  belongs_to :team
  has_many :project_results, dependent: :restrict_with_error

  validates :customer, :qty_hours, :product, :project_type, :name, :status, :start_date, :end_date, :status, :initial_scope, presence: true

  validate :hour_value_project_value?

  delegate :name, to: :customer, prefix: true
  delegate :name, to: :product, prefix: true, allow_nil: true

  def total_days
    (end_date - start_date).to_i
  end

  def remaining_days
    return 0 if end_date < Time.zone.today || start_date > Time.zone.today
    (end_date - Time.zone.today).to_i
  end

  def consumed_hours
    project_results.sum(&:project_delivered_hours)
  end

  def remaining_money
    hour_value_calc = hour_value || (value / qty_hours)
    value - (consumed_hours * hour_value_calc)
  end

  def red?
    return false unless executing?
    money_percentage = remaining_money / value
    time_percentage = remaining_days.to_f / total_days.to_f
    money_percentage < time_percentage
  end

  def current_backlog
    project_results.order(result_date: :desc).first&.known_scope || initial_scope
  end

  def current_team
    project_results.order(result_date: :desc)&.first&.team
  end

  private

  def hour_value_project_value?
    return true if hour_value.present? || value.present?
    errors.add(:value, I18n.t('project.validations.no_value'))
    errors.add(:hour_value, I18n.t('project.validations.no_value'))
  end
end
