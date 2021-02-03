# frozen_string_literal: true

class ProjectService
  include Singleton

  def risk_data_by_week(project)
    project.project_consolidations.weekly_data.order(:consolidation_date).map { |consolidation| (consolidation.operational_risk * 100).to_f }
  end

  def risk_data_by_week_team_data(project)
    project.project_consolidations.weekly_data.order(:consolidation_date).map { |consolidation| (consolidation.team_based_operational_risk * 100).to_f }
  end
end
