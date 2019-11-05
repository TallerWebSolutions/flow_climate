# frozen_string_literal: true

class TeamsController < AuthenticatedController
  before_action :user_gold_check

  before_action :assign_company
  before_action :assign_team, except: %i[new create]

  def show
    assign_demands_list
    assign_demands_ids
    assign_team_objects
    build_query_dates

    @report_data = Highchart::OperationalChartsAdapter.new(@demands, start_date, end_date, 'week')
    @team_chart_data = Highchart::TeamChartsAdapter.new(@team, start_date, end_date, 'week')
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
    return redirect_to company_team_path(@company, @team) if @team.save

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
    @projects_summary = ProjectsSummaryData.new(projects.except(:limit, :offset))
    @target_name = @team.name

    respond_to { |format| format.js { render 'projects/projects_tab' } }
  end

  def dashboard_search
    assign_team_objects
    assign_demands_list

    @demands_searched = search_status
    @demands_searched = search_demand_type(@demands_searched)
    @demands_searched = search_class_of_service(@demands_searched)

    @report_data = Highchart::OperationalChartsAdapter.new(@demands_searched, start_date, end_date, 'week')
    @team_chart_data = Highchart::TeamChartsAdapter.new(@team, start_date, end_date, 'week')

    respond_to { |format| format.js { render 'teams/dashboard_search' } }
  end

  def demands_tab
    assign_demands_list
    respond_to { |format| format.js { render 'teams/demands_tab' } }
  end

  def dashboard_tab
    respond_to { |format| format.js { render 'teams/dashboard_tab' } }
  end

  private

  def search_status
    if params['project_status'] == 'active'
      @demands.joins(:project).merge(Project.active)
    else
      @demands
    end
  end

  def search_class_of_service(demands_searched)
    if params['class_of_service'] == 'standard'
      demands_searched.standard
    elsif params['class_of_service'] == 'expedite'
      demands_searched.expedite
    elsif params['class_of_service'] == 'fixed_date'
      demands_searched.fixed_date
    elsif params['class_of_service'] == 'intangible'
      demands_searched.intangible
    else
      demands_searched
    end
  end

  def search_demand_type(demands_searched)
    return demands_searched unless params['demand_type'].present? && params['demand_type'] != 'all_types' && demands_searched.respond_to?(params['demand_type'])

    demands_searched.send(params['demand_type'])
  end

  def start_date
    params[:start_date]&.to_date || projects.active.map(&:start_date).compact.min || Time.zone.today
  end

  def end_date
    params[:end_date]&.to_date || projects.active.map(&:end_date).compact.max || Time.zone.today
  end

  def projects
    @projects ||= @team.projects.includes(:customers).includes(:products).includes(:team).order(end_date: :desc).page(page_param)
  end

  def build_query_dates
    @start_date = start_date
    @end_date = end_date
  end

  def assign_team_objects
    @memberships = @company.memberships.includes(:team).includes(:team_member).where(team: @team).sort_by(&:team_member_name)
    @slack_configurations = @team.slack_configurations.order(:created_at)
  end

  def assign_team
    @team = Team.find(params[:id])
  end

  def team_params
    params.require(:team).permit(:name, :max_work_in_progress)
  end

  def assign_demands_list
    @demands = @team.demands.kept.order(:end_date)
    @paged_demands = @demands.page(page_param)
  end

  def assign_demands_ids
    @demands_ids = @demands.map(&:id)
  end
end
