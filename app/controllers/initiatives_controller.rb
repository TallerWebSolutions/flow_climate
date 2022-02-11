# frozen_string_literal: true

class InitiativesController < AuthenticatedController
  before_action :assign_company
  before_action :assign_initiative, except: :index

  def index
    @initiatives = @company.initiatives.order(start_date: :desc)
  end

  def show
    tasks = Task.where(id: @initiative.tasks.map(&:id))
    @initiative_consolidations = @initiative.initiative_consolidations.weekly_data.order(:consolidation_date)
    @tasks_completed = tasks.finished.count
    @tasks_to_do = tasks.count - @tasks_completed

    @burnup_adapter = Highchart::BurnupAdapter.new(tasks, @initiative.start_date, @initiative.end_date)
    @tasks_charts_adapter = Highchart::TasksChartsAdapter.new(tasks.map(&:id), @initiative.start_date, @initiative.end_date)
  end

  def generate_cache
    start_date = @initiative.start_date
    end_date = [@initiative.end_date, Time.zone.today].min

    @initiative.initiative_consolidations.outdated_consolidations(start_date, end_date).map(&:destroy)

    (start_date..end_date).each do |consolidation_date|
      Consolidations::InitiativeConsolidationJob.perform_later(@initiative, consolidation_date)
    end

    flash[:notice] = I18n.t('general.enqueued')

    redirect_to company_initiative_path(@company, @initiative)
  end

  private

  def assign_initiative
    @initiative = @company.initiatives.find(params[:id])
  end
end
