# frozen_string_literal: true

# == Schema Information
#
# Table name: tasks
#
#  id                  :integer          not null, primary key
#  demand_id           :integer          not null
#  created_date        :datetime         not null
#  title               :string           not null
#  external_id         :integer
#  seconds_to_complete :integer
#  end_date            :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  discarded_at        :datetime
#  work_item_type_id   :integer          not null
#
# Indexes
#
#  index_tasks_on_demand_id          (demand_id)
#  index_tasks_on_discarded_at       (discarded_at)
#  index_tasks_on_work_item_type_id  (work_item_type_id)
#

class Task < ApplicationRecord
  include Discard::Model

  belongs_to :demand
  belongs_to :work_item_type

  scope :not_discarded_until, ->(date) { where('tasks.discarded_at IS NULL OR tasks.discarded_at > :limit_date', limit_date: date) }
  scope :finished, ->(date = Time.zone.now) { not_discarded_until(date).where('tasks.end_date <= :limit_date', limit_date: date).order(:end_date) }
  scope :open, ->(date = Time.zone.now) { not_discarded_until(date).where('tasks.created_date <= :limit_date AND tasks.end_date IS NULL', limit_date: date).order(:created_date) }
  scope :finished_between, ->(start_date, end_date) { kept.where('tasks.end_date BETWEEN :start_date AND :end_date', start_date: start_date.to_date.beginning_of_day, end_date: end_date.to_date.end_of_day) }
  scope :opened_between, ->(start_date, end_date) { kept.where('tasks.created_date BETWEEN :start_date AND :end_date', start_date: start_date.to_date.beginning_of_day, end_date: end_date.to_date.end_of_day) }

  validates :title, :created_date, presence: true

  before_save :compute_time_to_deliver

  def partial_completion_time
    return seconds_to_complete if seconds_to_complete.present?

    (Time.zone.now - created_date).to_i
  end

  def task_type
    work_item_type.name
  end

  private

  def compute_time_to_deliver
    self.seconds_to_complete = (end_date - created_date).to_i if end_date.present?
    self.discarded_at = demand.discarded_at if demand.discarded?
  end
end
