# frozen_string_literal: true

# == Schema Information
#
# Table name: initiatives
#
#  id         :bigint           not null, primary key
#  end_date   :date             not null
#  name       :string           not null
#  start_date :date             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  company_id :integer          not null
#
# Indexes
#
#  index_initiatives_on_company_id           (company_id)
#  index_initiatives_on_company_id_and_name  (company_id,name) UNIQUE
#  index_initiatives_on_name                 (name)
#
# Foreign Keys
#
#  fk_rails_8fd87a6ae5  (company_id => companies.id)
#

class Initiative < ApplicationRecord
  belongs_to :company

  has_many :projects, dependent: :nullify
  has_many :demands, through: :projects
  has_many :tasks, through: :projects

  has_many :initiative_consolidations, class_name: 'Consolidations::InitiativeConsolidation', dependent: :destroy

  validates :name, :start_date, :end_date, presence: true

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
