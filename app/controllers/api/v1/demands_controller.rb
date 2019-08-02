# frozen_string_literal: true

module Api
  module V1
    class DemandsController < AuthenticatedApiController
      def show
        demand = Demand.where('lower(demand_id) = :demand_id', demand_id: params[:id]&.downcase).first

        return not_found if demand.blank?

        render json: { status: 'SUCCESS', message: I18n.t('demands.show.title'), data: demand.to_hash }, status: :ok
      end
    end
  end
end
