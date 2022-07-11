# frozen_string_literal: true

# == Schema Information
#
# Table name: initiatives
#
#  id             :bigint           not null, primary key
#  end_date       :date             not null
#  name           :string           not null
#  start_date     :date             not null
#  target_quarter :integer          default(1), not null
#  target_year    :integer          default(2022), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  company_id     :integer          not null
#
# Indexes
#
#  index_initiatives_on_company_id           (company_id)
#  index_initiatives_on_company_id_and_name  (company_id,name) UNIQUE
#  index_initiatives_on_name                 (name)
#  index_initiatives_on_target_quarter       (target_quarter)
#  index_initiatives_on_target_year          (target_year)
#
# Foreign Keys
#
#  fk_rails_8fd87a6ae5  (company_id => companies.id)
#

class Initiative < ApplicationRecord
  enum target_quarter: { q1: 1, q2: 2, q3: 3, q4: 4 }

  belongs_to :company

  has_many :projects, dependent: :nullify
  has_many :demands, through: :projects
  has_many :tasks, through: :projects

  has_many :initiative_consolidations, class_name: 'Consolidations::InitiativeConsolidation', dependent: :destroy

  validates :name, :start_date, :end_date, :target_quarter, :target_year, presence: true

  validates :name, uniqueness: { scope: :company_id, case_sensitive: false }

  before_save :set_dates

  def remaining_weeks(from_date = Time.zone.today)
    start_date_limit = [start_date, from_date].max
    return 0 if end_date < start_date_limit

    ((start_date_limit.end_of_week.upto(end_date.to_date.end_of_week).count.to_f + 1) / 7).round + 1
  end

  def current_tasks_operational_risk
    return 0 if initiative_consolidations.blank?

    last_consolidation.tasks_operational_risk
  end

  def last_update
    return nil if initiative_consolidations.blank?

    last_consolidation.updated_at
  end

  def remaining_backlog_tasks_percentage
    return 1 if tasks.blank?

    total_tasks = tasks.count
    finished_tasks_count = tasks.finished.count

    finished_tasks_count.to_f / total_tasks
  end

  private

  def last_consolidation
    initiative_consolidations.order(:consolidation_date).last
  end

  def set_dates
    return if projects.blank?

    self.start_date = projects.map(&:start_date).min
    self.end_date = projects.map(&:end_date).max
  end
end
