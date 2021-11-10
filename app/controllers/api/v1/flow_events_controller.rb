# frozen_string_literal: true

module Api
  module V1
    class FlowEventsController < AuthenticatedApiController
      def create
        @demand = @company.demands.find_by(external_id: flow_event_params[:demand_id])
        @flow_event = FlowEvent.new(flow_event_params.merge(company: @company))

        if @flow_event.save
          render json: { status: 'SUCCESS', message: I18n.t('flow_events.create.success'), data: @flow_event }, status: :ok
        else
          render json: { status: 'ERROR', message: I18n.t('flow_events.create.error'), data: @flow_event.errors.full_messages.join(' | ') }, status: :bad_request
        end
      end

      def opened_events
        flow_events = @company.flow_events.order(:event_date)

        render json: { status: 'SUCCESS', message: I18n.t('flow_events.opened_events.title', company_name: @company.name), data: flow_events.map(&:to_hash) }, status: :ok
      end

      private

      def flow_event_params
        params.require(:flow_event).permit(:company_id, :team_id, :project_id, :event_date, :event_description, :event_type, :event_size)
      end
    end
  end
end
