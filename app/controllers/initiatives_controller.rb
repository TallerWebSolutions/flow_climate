# frozen_string_literal: true

class InitiativesController < AuthenticatedController
  before_action :assign_company
  before_action :assign_initiative, except: :index

  def index
    @initiatives = @company.initiatives.order(start_date: :desc)
  end

  def show; end

  def generate_cache
    start_date = @initiative.start_date
    end_date = @initiative.end_date

    @initiative.initiative_consolidations.outdated_consolidations(start_date, end_date).map(&:destroy)

    (start_date..end_date).each do |consolidation_date|
      Consolidations::InitiativeConsolidationJob.perform_later(@initiative, consolidation_date)
    end

    redirect_to company_initiative_path(@company, @initiative)
  end

  private

  def assign_initiative
    @initiative = @company.initiatives.find(params[:id])
  end
end
