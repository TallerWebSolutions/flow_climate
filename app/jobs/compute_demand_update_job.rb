# frozen_string_literal: true

class ComputeDemandUpdateJob < ApplicationJob
  queue_as :default

  def perform(team_id, demand_id)
    team = Team.find_by(id: team_id)
    demand = Demand.find_by(id: demand_id)
    ProjectResultService.instance.compute_demand!(team, demand) if team.present? && demand.present?
  end
end
