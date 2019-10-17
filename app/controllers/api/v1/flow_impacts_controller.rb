# frozen_string_literal: true

module Api
  module V1
    class FlowImpactsController < AuthenticatedApiController
      before_action :assigns_project

      def create
        @demand = @company.demands.find_by(external_id: flow_impact_params[:demand_id])
        @flow_impact = FlowImpact.new(flow_impact_params.merge(project: @project, demand: @demand))

        if @flow_impact.save
          render json: { status: 'SUCCESS', message: I18n.t('flow_impacts.create.success'), data: @flow_impact }, status: :ok
        else
          render json: { status: 'ERROR', message: I18n.t('flow_impacts.create.error'), data: @flow_impact.errors.full_messages.join(' | ') }, status: :bad_request
        end
      end

      def opened_impacts
        flow_impacts = @project.flow_impacts.opened.order(:start_date)

        render json: { status: 'SUCCESS', message: I18n.t('flow_impacts.opened_impacts.title', project_name: @project.name), data: flow_impacts.map(&:to_hash) }, status: :ok
      end

      private

      def assigns_project
        @project = @company.projects.find(params[:project_id])
      end

      def flow_impact_params
        params.require(:flow_impact).permit(:demand_id, :start_date, :end_date, :impact_description, :impact_type)
      end
    end
  end
end
