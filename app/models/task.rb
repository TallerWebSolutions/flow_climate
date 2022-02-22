# frozen_string_literal: true

# == Schema Information
#
# Table name: tasks
#
#  id                  :bigint           not null, primary key
#  created_date        :datetime         not null
#  discarded_at        :datetime
#  end_date            :datetime
#  seconds_to_complete :integer
#  title               :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  demand_id           :integer          not null
#  external_id         :integer
#
# Indexes
#
#  index_tasks_on_demand_id     (demand_id)
#  index_tasks_on_discarded_at  (discarded_at)
#
# Foreign Keys
#
#  fk_rails_ae3913c114  (demand_id => demands.id)
#
class Task < ApplicationRecord
  include Discard::Model

  belongs_to :demand

  scope :not_discarded_until, ->(date) { where('tasks.discarded_at IS NULL OR tasks.discarded_at > :limit_date', limit_date: date) }
  scope :finished, ->(date = Time.zone.now) { not_discarded_until(date).where('tasks.end_date <= :limit_date', limit_date: date).order(:end_date) }
  scope :open, ->(date = Time.zone.now) { not_discarded_until(date).where('tasks.created_date <= :limit_date AND tasks.end_date IS NULL', limit_date: date).order(:created_date) }

  validates :title, :created_date, presence: true

  before_save :compute_time_to_deliver

  def partial_completion_time
    return seconds_to_complete if seconds_to_complete.present?

    (Time.zone.now - created_date).to_i
  end

  private

  def compute_time_to_deliver
    self.seconds_to_complete = (end_date - created_date).to_i if end_date.present?
    self.discarded_at = demand.discarded_at if demand.discarded?
  end
end
