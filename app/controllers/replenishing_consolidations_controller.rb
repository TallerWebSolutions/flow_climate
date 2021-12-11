# frozen_string_literal: true

class ReplenishingConsolidationsController < AuthenticatedController
  prepend_view_path Rails.root.join('public')

  before_action :assign_company

  def index
    assign_team

    @replenishing_consolidations = []
    @team.projects.running.each do |project|
      consolidation = Consolidations::ReplenishingConsolidation.where(project: project).order(:consolidation_date).last
      @replenishing_consolidations << consolidation if consolidation.present?
    end

    render 'spa-build/index'
  end

  def refresh_cache
    assign_team

    Consolidations::ReplenishingConsolidationJob.perform_later

    flash[:notice] = I18n.t('general.enqueued')

    respond_to { |format| format.js { render 'replenishing_consolidations/refresh_cache' } }
  end

  private

  def assign_team
    @team = @company.teams.find(params[:team_id])
  end
end
