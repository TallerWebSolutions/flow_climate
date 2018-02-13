# frozen_string_literal: true

class DemandsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_project
  before_action :assign_project_result, except: %i[import_csv_form import_csv]

  def new
    @demand = Demand.new
  end

  def create
    @demand = Demand.new(demand_params.merge(project_result: @project_result))
    return redirect_to company_project_project_result_path(@company, @project, @project_result) if @demand.save
    render :new
  end

  def destroy
    demand = Demand.find(params[:id])
    demand.destroy
    redirect_to company_project_project_result_path(@company, @project, @project_result)
  end

  def import_csv_form
    assign_teams_to_select
  end

  def import_csv
    team = Team.where(id: params[:team]).first
    CSV.parse(params[:csv_text]) do |row|
      row_parts = row.first.split(';')
      return process_malformed_csv_string if row_parts.count < 3
      process_row_parts(row_parts, team)
    end
    redirect_to company_project_path(@company, @project)
  end

  private

  def process_malformed_csv_string
    flash[:error] = t('demands.import_csv.bad_string')
    assign_teams_to_select
    render :import_csv_form
  end

  def assign_teams_to_select
    @teams = @company.teams.order(:name)
  end

  def process_row_parts(row_parts, team)
    demand = Demand.where(demand_id: row_parts[0]).first_or_initialize
    created_date = Time.iso8601(row_parts[2])
    commitment_date = nil
    end_date = nil

    commitment_date = Time.iso8601(row_parts[3]) if row_parts[3].present?
    end_date = Time.iso8601(row_parts[4]) if row_parts[4].present?

    create_demand(commitment_date, created_date, demand, end_date, row_parts, team)
  end

  def create_demand(commitment_date, created_date, demand, end_date, row_parts, team)
    result_date = end_date || created_date
    project_result = ProjectResultsRepository.instance.create_project_result(@project, team, result_date)
    hours_consumed = DemandService.instance.compute_effort_for_dates(commitment_date, end_date)
    demand.update(project_result: project_result, demand_type: row_parts[1], created_date: created_date, commitment_date: commitment_date, end_date: end_date, effort: hours_consumed)
    known_scope = ProjectsRepository.instance.known_scope(@project, result_date)
    ProjectResultsRepository.instance.update_result_for_date(@project, result_date, known_scope, 0)
  end

  def demand_params
    params.require(:demand).permit(:demand_id, :effort, :created_date)
  end

  def assign_project
    @project = Project.find(params[:project_id])
  end

  def assign_project_result
    @project_result = ProjectResult.find(params[:project_result_id])
  end
end
