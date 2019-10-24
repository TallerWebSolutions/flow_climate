# frozen_string_literal: true

class TeamsController < AuthenticatedController
  before_action :user_gold_check

  before_action :assign_company
  before_action :assign_team, only: %i[show edit update replenishing_input destroy projects_tab]

  def show
    assign_demands_ids
    assign_team_objects
    build_query_dates
  end

  def new
    @team = Team.new(company: @company)
  end

  def create
    @team = Team.new(team_params.merge(company: @company))
    return redirect_to company_team_path(@company, @team) if @team.save

    render :new
  end

  def edit; end

  def update
    @team.update(team_params.merge(company: @company))
    return redirect_to company_path(@company) if @team.save

    render :edit
  end

  def replenishing_input
    @replenishing_data = ReplenishingData.new(@team)

    render 'teams/replenishing_input'
  end

  def destroy
    team_name = @team.name

    @team.destroy
    if @team.errors.full_messages.present?
      flash[:error] = @team.errors.full_messages.join(' | ')
    else
      flash[:notice] = I18n.t('teams.destroy.success', team_name: team_name)
    end

    @teams = @company.teams.order(:name)
    build_query_dates
    respond_to { |format| format.js { render 'teams/destroy' } }
  end

  def projects_tab
    @projects = @team.projects.includes(:customers).includes(:products).includes(:team).order(end_date: :desc).page(page_param)

    @projects_summary = ProjectsSummaryData.new(@projects.except(:limit, :offset))
    @target_name = @team.name

    respond_to { |format| format.js { render 'projects/projects_tab' } }
  end

  private

  def build_query_dates
    @start_date = build_limit_date(team_projects.map(&:start_date).min)
    @end_date = build_limit_date(team_projects.map(&:end_date).max)
  end

  def assign_team_objects
    @memberships = @company.memberships.includes(:team).includes(:team_member).where(team: @team).sort_by(&:team_member_name)
    @slack_configurations = @team.slack_configurations.order(:created_at)
  end

  def team_projects
    @team_projects ||= ProjectsRepository.instance.all_projects_for_team(@team)
                                         .includes(:team)
                                         .includes(:customers)
                                         .includes(customers_projects: :customer)
                                         .includes(:products)
                                         .includes(products_projects: :product)
                                         .order(end_date: :desc)
                                         .page(page_param)
  end

  def assign_team
    @team = Team.find(params[:id])
  end

  def team_params
    params.require(:team).permit(:name, :max_work_in_progress)
  end

  def assign_demands_ids
    @demands_ids = @team.demands.map(&:id)
  end
end
