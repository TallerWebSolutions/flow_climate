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

    demands_searched = team_demands_search_engine(@demands)

    build_charts_data(demands_searched)
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

  def team_projects_tab
    executing_projects = @team.projects.running

    build_projects_lead_time_in_time_array(executing_projects)

    respond_to { |format| format.js { render 'teams/team_projects_tab' } }
  end

  def dashboard_search
    assign_team_objects
    assign_demands_list

    @demands_searched = team_demands_search_engine(@demands)

    build_charts_data(@demands_searched)
    @paged_demands_searched = @demands_searched.page(page_param)

    @demands_ids = @demands_searched.map(&:id)

    respond_to { |format| format.js { render 'teams/dashboard_search' } }
  end

  def demands_tab
    demands
    @paged_demands = @demands.page(page_param)
    respond_to { |format| format.js { render 'teams/demands_tab' } }
  end

  def dashboard_tab
    demands
    respond_to { |format| format.js { render 'teams/dashboard_tab' } }
  end

  def dashboard_page_two
    demands
    @team_chart_data = Highchart::TeamChartsAdapter.new(@team, start_date, end_date, 'week')

    respond_to { |format| format.js { render 'teams/dashboard_page_two' } }
  end

  def dashboard_page_three
    @demands_chart_adapter = Highchart::DemandsChartsAdapter.new(demands, start_date, Time.zone.today, 'week')
    @array_of_dates = @demands_chart_adapter.x_axis

    respond_to { |format| format.js { render 'teams/dashboard_page_three' } }
  end

  def dashboard_page_four
    @strategic_chart_data = Highchart::StrategicChartsAdapter.new(@company, [@team], @team.projects, demands, start_date, end_date, 'month')
    @target_name = @team.name
    @array_of_dates = @strategic_chart_data.x_axis

    respond_to { |format| format.js { render 'teams/dashboard_page_four' } }
  end

  private

  def build_projects_lead_time_in_time_array(executing_projects)
    @projects_lead_time_in_time = []
    @projects_risk_in_time = []
    array_of_dates = []
    executing_projects.each do |project|
      project_lead_times_hash = compute_project_lead_times(project)
      array_of_dates << project_lead_times_hash[:project_period]
      @projects_lead_time_in_time << project_lead_times_hash[:project_data]

      @projects_risk_in_time << { name: project.name, data: project.project_consolidations.map { |consolidation| (1 - consolidation.odds_to_deadline_project) * 100 } }
    end

    build_x_axis_index(array_of_dates)
  end

  def build_x_axis_index(array_of_dates)
    min_date = array_of_dates.flatten.sort_by(&:itself).min
    max_date = array_of_dates.flatten.sort_by(&:itself).max

    all_period = TimeService.instance.months_between_of(min_date, max_date)

    @x_axis_index = all_period.map { |value| all_period.find_index(value) + 1 }.flatten
  end

  def compute_project_lead_times(project)
    project_demands = project.demands
    project_period = TimeService.instance.weeks_between_of(project.start_date, Time.zone.today)

    statistics_informations = Flow::StatisticsFlowInformations.new(project_demands)
    project_period.each { |analysed_date| statistics_informations.statistics_flow_behaviour(analysed_date) }

    { project_period: project_period, project_data: { name: project.name, data: statistics_informations.lead_time_accumulated } }
  end

  def demands
    @demands ||= @team.demands.where(id: params[:demands_ids]&.split(',')).order(:end_date, :commitment_date, :created_date)
  end

  def team_demands_search_engine(demands)
    demands_searched = demands.to_dates(start_date, end_date)
    demands_searched = search_demand_status(demands_searched)
    demands_searched = search_project_status(demands_searched)
    demands_searched = search_demand_type(demands_searched)
    search_class_of_service(demands_searched)
  end

  def build_charts_data(demands)
    @array_of_dates = TimeService.instance.weeks_between_of(start_date, end_date)
    @work_item_flow_information = Flow::WorkItemFlowInformations.new(demands, uncertain_scope, @array_of_dates.length, @array_of_dates.last)
    @statistics_flow_information = Flow::StatisticsFlowInformations.new(demands)
    @time_flow_informations = Flow::TimeFlowInformations.new(demands)

    build_chart_objects
  end

  def build_chart_objects
    @array_of_dates.each_with_index do |analysed_date, distribution_index|
      @work_item_flow_information.work_items_flow_behaviour(@array_of_dates.first, analysed_date, distribution_index)
      @work_item_flow_information.build_cfd_hash(@array_of_dates.first, analysed_date) if add_data?(analysed_date)
      @statistics_flow_information.statistics_flow_behaviour(analysed_date) if add_data?(analysed_date)
      @time_flow_informations.hours_flow_behaviour(analysed_date) if add_data?(analysed_date)
    end
  end

  def add_data?(analysed_date)
    analysed_date < Time.zone.now.end_of_week
  end

  def uncertain_scope
    @team.projects.map(&:initial_scope).compact.sum
  end

  def search_project_status(demands_searched)
    if params['project_status'] == 'active'
      demands_searched.joins(:project).merge(Project.active)
    else
      demands_searched
    end
  end

  def search_demand_status(demands_searched)
    if params['demand_status'] == 'finished'
      demands_searched.finished
    else
      demands_searched
    end
  end

  def search_class_of_service(demands_searched)
    if params['demand_class_of_service'] == 'standard'
      demands_searched.standard
    elsif params['demand_class_of_service'] == 'expedite'
      demands_searched.expedite
    elsif params['demand_class_of_service'] == 'fixed_date'
      demands_searched.fixed_date
    elsif params['demand_class_of_service'] == 'intangible'
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
    @projects ||= @team.projects.order(end_date: :desc).page(page_param)
  end

  def build_query_dates
    @start_date = start_date
    @end_date = end_date
  end

  def assign_team_objects
    @memberships = @company.memberships.includes(:team_member).where(team: @team).sort_by(&:team_member_name)
    @slack_configurations = @team.slack_configurations.order(:created_at)
  end

  def assign_team
    @team = @company.teams.find(params[:id])
  end

  def team_params
    params.require(:team).permit(:name, :max_work_in_progress)
  end

  def assign_demands_list
    @demands = @team.demands.kept.order(:end_date)
    @paged_demands = @demands.includes(:demand_blocks).includes(:current_stage).includes(:project).includes(:portfolio_unit).includes(:product).page(page_param)
  end

  def assign_demands_ids
    @demands_ids = @demands.map(&:id)
  end
end
