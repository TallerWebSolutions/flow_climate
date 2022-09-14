# frozen_string_literal: true

# == Schema Information
#
# Table name: project_risk_configs
#
#  id                :bigint           not null, primary key
#  active            :boolean          default(TRUE)
#  high_yellow_value :decimal(, )      not null
#  low_yellow_value  :decimal(, )      not null
#  risk_type         :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  project_id        :integer          not null
#
# Indexes
#
#  index_project_risk_configs_on_project_id  (project_id)
#

class ProjectRiskConfig < ApplicationRecord
  enum risk_type: { no_money_to_deadline: 0, backlog_growth_rate: 1, not_enough_available_hours: 2, profit_margin: 3, flow_pressure: 4 }

  belongs_to :project
  has_many :project_risk_alerts, dependent: :destroy

  validates :risk_type, :high_yellow_value, :low_yellow_value, presence: true

  scope :active, -> { where active: true }

  def activate!
    update(active: true)
  end

  def deactivate!
    update(active: false)
  end
end
