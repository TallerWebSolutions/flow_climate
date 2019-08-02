# frozen_string_literal: true

module Api
  module V1
    class TeamsController < AuthenticatedApiController
      def average_demand_cost
        team = @company.teams.find(params[:id])
        average_demand_cost_info = TeamService.instance.average_demand_cost_info_hash(team)

        render json: { status: 'SUCCESS', message: I18n.t('teams.average_demand_cost.message'), data: average_demand_cost_info }, status: :ok
      end

      def items_in_wip
        team = @company.teams.find(params[:id])
        team_demands_in_wip = team.demands.kept.in_wip

        render json: { status: 'SUCCESS', message: I18n.t('teams.items_in_wip.message'), data: team_demands_in_wip.map(&:to_hash) }, status: :ok
      end
    end
  end
end
