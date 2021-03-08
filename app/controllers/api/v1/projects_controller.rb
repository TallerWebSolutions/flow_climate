# frozen_string_literal: true

module Api
  module V1
    class ProjectsController < AuthenticatedApiController
      def show
        project = @company.projects.find(params[:id])

        render json: { status: 'SUCCESS', message: I18n.t('projects.api.show.message'), data: project.to_hash }, status: :ok
      end
    end
  end
end
