# frozen_string_literal: true

module Api
  module V1
    class CompaniesController < AuthenticatedApiController
      def show
        company = Company.find(params[:id])

        render json: { status: 'SUCCESS', message: I18n.t('companies.api.company_details.message'), data: company.to_hash }, status: :ok
      end
    end
  end
end
