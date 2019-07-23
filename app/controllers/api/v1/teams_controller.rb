# frozen_string_literal: true

module Api
  module V1
    class TeamsController < AuthenticatedApiController
      def average_demand_cost
        team = @company.teams.find(params[:id])
        average_demand_cost_info = TeamService.instance.average_demand_cost_info_hash(team)

        render json: { status: 'SUCCESS', message: I18n.t('teams.average_demand_cost.message'), data: average_demand_cost_info }, status: :ok
      end
    end
  end
end
