# frozen_string_literal: true

class ProjectResultsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_project
  before_action :assign_team, only: %i[create update]
  before_action :assign_project_result, only: %i[destroy edit update show]

  def show
    @demands = @project_result.demands.sort_by(&:result_date).reverse.group_by { |demand| [demand.result_date.to_date.cwyear, demand.result_date.to_date.month] }
  end

  def new
    @project_result = ProjectResult.new(project: @project)
    @last_known_scope = @project.project_results.order(:result_date).last&.known_scope
    assign_company_teams
  end

  def create
    @project_result = ProjectResult.new(project_result_params.merge(project: @project, team: @team))
    @project_result.define_automatic_attributes! if @project_result.valid?
    return redirect_to company_project_path(@company, @project) if @project_result.save
    assign_company_teams
    render :new
  end

  def destroy
    assign_project_result
    @project_result.destroy
    redirect_to company_project_path(@company, @project)
  end

  def edit
    assign_company_teams
  end

  def update
    @project_result.update(project_result_params.merge(project: @project, team: @team))
    @project_result.define_automatic_attributes! if @project_result.valid?
    return redirect_to company_project_path(@company, @project) if @project_result.save
    assign_company_teams
    render :edit
  end

  private

  def assign_company_teams
    @company_teams = @company.teams.order(:name)
  end

  def assign_team
    @team = Team.find_by(id: project_result_params[:team])
  end

  def assign_project_result
    @project_result = ProjectResult.find(params[:id])
  end

  def project_result_params
    params.require(:project_result).permit(:team, :result_date, :known_scope, :qty_hours_upstream, :qty_hours_downstream, :throughput_upstream, :throughput_downstream, :monte_carlo_date, :qty_bugs_opened, :qty_bugs_closed, :qty_hours_bug, :leadtime, :flowpressure)
  end

  def assign_project
    @project = Project.find(params[:project_id])
  end
end
