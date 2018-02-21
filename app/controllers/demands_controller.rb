# frozen_string_literal: true

class DemandsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_project
  before_action :assign_project_result, except: %i[import_csv_form import_csv]
  before_action :assign_demand, only: %i[edit update]

  def new
    @demand = Demand.new
  end

  def create
    @demand = Demand.new(demand_params.merge(project_result: @project_result))
    if @demand.save
      update_project_results(@demand)
      return redirect_to company_project_project_result_path(@company, @project, @project_result)
    end
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

  def edit; end

  def update
    previous_date = @demand.end_date || @demand.created_date

    if @demand.update(demand_params)
      update_project_results(@demand, previous_date)
      return redirect_to company_project_project_result_path(@company, @project, @project_result)
    end

    render :edit
  end

  private

  def update_project_results(demand, previous_date = nil)
    if previous_date.present?
      known_scope = ProjectsRepository.instance.known_scope(@project, previous_date)
      ProjectResultsRepository.instance.update_result_for_date(@project, previous_date, known_scope, 0)
    end

    current_date = demand.end_date || demand.created_date
    known_scope = ProjectsRepository.instance.known_scope(@project, current_date.to_date)
    ProjectResultsRepository.instance.update_result_for_date(@project, current_date, known_scope, 0)
  end

  def process_malformed_csv_string
    flash[:error] = t('demands.import_csv.bad_string')
    assign_teams_to_select
    render :import_csv_form
  end

  def assign_teams_to_select
    @teams = @company.teams.order(:name)
  end

  def process_row_parts(row_parts, team)
    created_date = Time.iso8601(row_parts[2])
    commitment_date = nil
    end_date = nil

    commitment_date = Time.iso8601(row_parts[3]) if row_parts[3].present?
    end_date = Time.iso8601(row_parts[4]) if row_parts[4].present?

    DemandsRepository.instance.create_or_update_demand(@project, team, row_parts[0], row_parts[1], commitment_date, created_date, end_date, '')
  end

  def demand_params
    params.require(:demand).permit(:demand_id, :demand_type, :class_of_service, :effort, :created_date, :commitment_date, :end_date)
  end

  def assign_project
    @project = Project.find(params[:project_id])
  end

  def assign_project_result
    @project_result = ProjectResult.find(params[:project_result_id])
  end

  def assign_demand
    @demand = Demand.find(params[:id])
  end
end
