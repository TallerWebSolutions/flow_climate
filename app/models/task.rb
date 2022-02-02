# frozen_string_literal: true

# == Schema Information
#
# Table name: tasks
#
#  id                  :bigint           not null, primary key
#  created_date        :datetime         not null
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
#  index_tasks_on_demand_id  (demand_id)
#
# Foreign Keys
#
#  fk_rails_ae3913c114  (demand_id => demands.id)
#
class Task < ApplicationRecord
  belongs_to :demand

  scope :finished, ->(date = Time.zone.now) { where('tasks.end_date <= :limit_date', limit_date: date).order(:end_date) }
  scope :open, ->(date = Time.zone.now) { where('tasks.created_date <= :limit_date AND tasks.end_date IS NULL', limit_date: date).order(:created_date) }

  validates :title, :created_date, presence: true

  before_save :compute_time_to_deliver

  private

  def compute_time_to_deliver
    self.seconds_to_complete = (end_date - created_date).to_i if end_date.present?
  end
end
