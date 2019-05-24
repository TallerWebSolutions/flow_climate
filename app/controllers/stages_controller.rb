# frozen_string_literal: true

class StagesController < AuthenticatedController
  before_action :user_gold_check

  before_action :assign_company
  before_action :assign_stage, except: %i[new create import_from_jira]

  def new
    @stage = Stage.new
  end

  def create
    @stage = Stage.new(stages_params.merge(company: @company))
    return redirect_to company_path(@company) if @stage.save

    render :new
  end

  def edit
    respond_to { |format| format.js }
  end

  def update
    @stage.update(stages_params)
    render 'stages/update'
  end

  def destroy
    return redirect_to company_path(@company) if @stage.destroy

    redirect_to(company_path(@company), flash: { error: @stage.errors.full_messages.join(',') })
  end

  def show
    @not_associated_projects = (@company.projects.includes(:team) - @stage.projects.includes(:team)).sort_by(&:full_name)
    @stage_projects = @stage.projects.includes(:team).includes(:product).includes(:customer).sort_by(&:full_name)
    @transitions_in_stage = @stage.demand_transitions.includes(:demand)
    @provider_stages = (@company.stages - [@stage]).sort_by(&:name)
    @stage_analytic_data = StageAnalyticData.new(@stage)
  end

  def associate_project
    project = Project.find(params[:project_id])
    @stage.add_project!(project)
    redirect_to company_stage_path(@company, @stage)
  end

  def dissociate_project
    project = Project.find(params[:project_id])
    @stage.remove_project!(project)
    redirect_to company_stage_path(@company, @stage)
  end

  def copy_projects_from
    provider_stage = Stage.find(params[:provider_stage_id])
    @stage.update(projects: provider_stage.projects)
    redirect_to company_stage_path(@company, @stage)
  end

  def import_from_jira
    if @company.jira_accounts.present?
      jira_stages = Jira::JiraApiService.new(@company.jira_accounts.first.username, @company.jira_accounts.first.password, @company.jira_accounts.first.base_uri).request_status
      jira_stages.each(&method(:build_stage))
    end

    @stages_list = @company.stages.includes(:team).order('teams.name, stages.order')
  end

  private

  def build_stage(jira_stage)
    imported_stage = Stage.where(integration_id: jira_stage.attrs['id'], company: @company).first_or_initialize
    imported_stage.update(name: jira_stage.attrs['name'])
  end

  def stages_params
    params.require(:stage).permit(:order, :team_id, :integration_id, :name, :stage_type, :stage_stream, :commitment_point, :end_point, :queue)
  end

  def assign_stage
    @stage = @company.stages.find(params[:id])
  end
end
