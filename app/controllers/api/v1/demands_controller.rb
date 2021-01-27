# frozen_string_literal: true

module Api
  module V1
    class DemandsController < AuthenticatedApiController
      def show
        demand = @company.demands.where('lower(external_id) = :external_id', external_id: params[:id]&.downcase).first

        return not_found if demand.blank?

        render json: { status: 'SUCCESS', message: I18n.t('demands.show.title'), data: demand.to_hash }, status: :ok
      end
    end
  end
end
