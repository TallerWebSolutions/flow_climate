# frozen_string_literal: true

# == Schema Information
#
# Table name: project_risk_alerts
#
#  id                     :bigint           not null, primary key
#  alert_color            :integer          not null
#  alert_value            :decimal(, )      not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  project_id             :integer          not null
#  project_risk_config_id :integer          not null
#
# Indexes
#
#  index_project_risk_alerts_on_project_id              (project_id)
#  index_project_risk_alerts_on_project_risk_config_id  (project_risk_config_id)
#
# Foreign Keys
#
#  fk_rails_4685dfa1bb  (project_id => projects.id)
#  fk_rails_b8b501e2eb  (project_risk_config_id => project_risk_configs.id)
#

class ProjectRiskAlert < ApplicationRecord
  enum alert_color: { green: 0, yellow: 1, red: 2 }
  belongs_to :project
  belongs_to :project_risk_config

  validates :project, :project_risk_config, :alert_color, :alert_value, presence: true
end
