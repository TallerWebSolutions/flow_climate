# frozen_string_literal: true

# == Schema Information
#
# Table name: project_risk_configs
#
#  id                :integer          not null, primary key
#  risk_type         :integer          not null
#  high_yellow_value :decimal(, )      not null
#  low_yellow_value  :decimal(, )      not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  project_id        :integer          not null
#

class ProjectRiskConfig < ApplicationRecord
  enum risk_type: { no_money_to_deadline: 0, backlog_growth_rate: 1, not_enough_available_hours: 2, profit_margin: 3, flow_pressure: 4 }

  belongs_to :project

  validates :project, :risk_type, :high_yellow_value, :low_yellow_value, presence: true
end
