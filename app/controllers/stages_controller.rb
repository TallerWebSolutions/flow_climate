# frozen_string_literal: true

class StagesController < AuthenticatedController
  before_action :user_gold_check

  before_action :assign_company
  before_action :assign_stage, except: %i[new create import_from_jira]

  def new
    @stage = Stage.new
    parent_stages
  end

  def create
    @stage = Stage.new(stages_params.except(:team_id).merge(company: @company))
    @stage = StagesRepository.instance.save_stage(@stage, stages_params)
    return redirect_to company_path(@company) if @stage.valid?

    parent_stages
    render :new
  end

  def edit
    parent_stages

    respond_to { |format| format.js }
  end

  def update
    parent_stages
    @stage = StagesRepository.instance.save_stage(@stage, stages_params)
    render 'stages/update'
  end

  def destroy
    return redirect_to company_path(@company) if @stage.destroy

    redirect_to(company_path(@company), flash: { error: @stage.errors.full_messages.join(',') })
  end

  def show
    assign_project_stages
    assign_team_stages

    @transitions_in_stage = @stage.demand_transitions.includes(:demand)
    @stage_analytic_data = StageAnalyticData.new(@stage)
  end

  def associate_project
    project = Project.find(params[:project_id])
    @stage.add_project(project)
    redirect_to company_stage_path(@company, @stage)
  end

  def dissociate_project
    project = Project.find(params[:project_id])
    @stage.remove_project(project)
    redirect_to company_stage_path(@company, @stage)
  end

  def associate_team
    team = @company.teams.find(params[:team_id])
    @stage.add_team(team)
    assign_team_stages
    respond_to { |format| format.js { render 'stages/associate_dissociate_team' } }
  end

  def dissociate_team
    team = @company.teams.find(params[:team_id])
    @stage.remove_team(team)
    assign_team_stages
    respond_to { |format| format.js { render 'stages/associate_dissociate_team' } }
  end

  def copy_projects_from
    provider_stage = Stage.find(params[:provider_stage_id])
    @stage.update(projects: provider_stage.projects)
    redirect_to company_stage_path(@company, @stage)
  end

  def import_from_jira
    update_stages_in_company
    assign_stages_list

    redirect_to company_stages_path(@company)
  end

  private

  def parent_stages
    @parent_stages = @company.stages.order(:name) - [@stage]
  end

  def assign_project_stages
    @stage_projects = @stage.projects.includes(:team).sort_by(&:name)
    @not_associated_projects = @company.projects.includes(:team) - @stage_projects
    @provider_stages = (@company.stages - [@stage]).sort_by(&:name)
  end

  def assign_team_stages
    @stage_teams = @stage.teams.order(:name)
    @not_associated_teams = @company.teams - @stage_teams
  end

  def update_stages_in_company
    return if @company.jira_accounts.blank?

    jira_stages = Jira::JiraApiService.new(@company.jira_accounts.first.username, @company.jira_accounts.first.api_token, @company.jira_accounts.first.base_uri).request_status
    jira_stages.each { |stage| build_stage(stage) }
  end

  def assign_stages_list
    @stages_list = @company.stages.order('stages.order')
  end

  def build_stage(jira_stage)
    imported_stage = Stage.where(integration_id: jira_stage.attrs['id'], company: @company).first_or_initialize
    imported_stage.update(name: jira_stage.attrs['name'])
  end

  def stages_params
    params.require(:stage).permit(:order, :team_id, :integration_pipe_id, :integration_id, :name, :stage_type, :stage_stream, :commitment_point, :end_point, :queue, :parent_id, :stage_level)
  end

  def assign_stage
    @stage = @company.stages.find(params[:id])
  end
end
