# frozen_string_literal: true

class InitiativesController < AuthenticatedController
  before_action :assign_company
  before_action :assign_initiative, except: %i[index new create]

  def index
    prepend_view_path Rails.public_path
    render 'spa-build/index'
  end

  def show
    tasks = Task.where(id: @initiative.tasks.map(&:id)).kept
    @initiative_consolidations = @initiative.initiative_consolidations.weekly_data.order(:consolidation_date)
    @tasks_completed = tasks.finished.count
    @tasks_to_do = tasks.count - @tasks_completed

    @burnup_adapter = Highchart::BurnupAdapter.new(tasks, @initiative.start_date, @initiative.end_date)
    @tasks_charts_adapter = ViewCharts::TasksCharts.new(tasks.map(&:id), @initiative.start_date, @initiative.end_date, 'WEEKLY')
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

  def new
    @initiative = Initiative.new(company: @company)
  end

  def create
    @initiative = Initiative.new(initiative_params.merge(company: @company))

    if @initiative.save
      flash[:notice] = I18n.t('initiatives.create.success')
      redirect_to company_initiatives_path(@company)
    else
      flash[:error] = I18n.t('initiatives.create.error')
      render :new
    end
  end

  private

  def assign_initiative
    @initiative = @company.initiatives.find(params[:id])
  end

  def initiative_params
    params.require(:initiative).permit(:name, :start_date, :end_date)
  end
end
