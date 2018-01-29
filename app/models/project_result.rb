# frozen_string_literal: true

# == Schema Information
#
# Table name: project_results
#
#  id                   :integer          not null, primary key
#  project_id           :integer          not null
#  result_date          :date             not null
#  known_scope          :integer          not null
#  qty_hours_upstream   :integer          not null
#  qty_hours_downstream :integer          not null
#  throughput           :integer          not null
#  qty_bugs_opened      :integer          not null
#  qty_bugs_closed      :integer          not null
#  qty_hours_bug        :integer          not null
#  leadtime             :decimal(, )
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  team_id              :integer          not null
#  monte_carlo_date     :date
#  demands_count        :integer
#
# Indexes
#
#  index_project_results_on_project_id  (project_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#  fk_rails_...  (team_id => teams.id)
#

class ProjectResult < ApplicationRecord
  belongs_to :team
  belongs_to :project
  has_many :demands, dependent: :destroy

  validates :project, :team, :known_scope, :qty_hours_upstream, :qty_hours_downstream, :qty_hours_bug, :qty_bugs_closed, :qty_bugs_opened, :throughput, :result_date, presence: true

  scope :for_week, ->(week, year) { where('EXTRACT(WEEK FROM result_date) = :week AND EXTRACT(YEAR FROM result_date) = :year', week: week, year: year) }
  scope :until_week, ->(week, year) { where('EXTRACT(WEEK FROM result_date) <= :week AND EXTRACT(YEAR FROM result_date) <= :year', week: week, year: year) }

  delegate :name, to: :team, prefix: true

  def project_delivered_hours
    qty_hours_upstream + qty_hours_downstream
  end

  def hours_per_demand
    project_delivered_hours / throughput
  end
end
