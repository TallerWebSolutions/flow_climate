# frozen_string_literal: true

module Api
  module V1
    class AuthenticatedApiController < ActionController::API
      rescue_from ActiveRecord::RecordNotFound, with: :not_found

      before_action :authenticate_request

      private

      def authenticate_request
        @company = Company.find_by(api_token: request.headers['HTTP_API_TOKEN'])
        render json: { error: 'Not Authorized' }, status: :unauthorized unless @company
      end

      def not_found
        render json: { status: 'NOT FOUND', message: I18n.t('general.not_found.message'), data: {} }, status: :not_found
      end
    end
  end
end
