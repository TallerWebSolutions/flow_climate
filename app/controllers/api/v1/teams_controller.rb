# frozen_string_literal: true

module Api
  module V1
    class TeamsController < AuthenticatedApiController
      def average_demand_cost
        team = @company.teams.find(params[:id])
        average_demand_cost_info = TeamService.instance.average_demand_cost_stats_info_hash(team)

        render json: { status: 'SUCCESS', message: I18n.t('teams.average_demand_cost.message'), data: average_demand_cost_info }, status: :ok
      end

      def items_in_wip
        team = @company.teams.find(params[:id])
        team_demands_in_wip = team.demands.kept.in_wip

        render json: { status: 'SUCCESS', message: I18n.t('teams.items_in_wip.message'), data: team_demands_in_wip.map(&:to_hash) }, status: :ok
      end

      def items_delivered_last_week
        team = @company.teams.find(params[:id])

        th_last_week = DemandsRepository.instance.throughput_to_period(team.demands, 1.week.ago.beginning_of_week, 1.week.ago.end_of_week)
        render json: { status: 'SUCCESS', message: I18n.t('teams.items_delivered_last_week.message'), data: th_last_week.map(&:to_hash) }, status: :ok
      end
    end
  end
end
