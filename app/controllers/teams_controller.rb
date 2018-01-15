# frozen_string_literal: true

class TeamsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_team, only: [:show]

  def index
    @teams = @company.teams.order(:name)
  end

  def show
    @team_members = @team.team_members.order(:name)
  end

  def new
    @team = Team.new(company: @company)
  end

  def create
    @team = Team.new(team_params.merge(company: @company))
    return redirect_to company_team_path(@company, @team) if @team.save
    render :new
  end

  private

  def assign_team
    @team = Team.find(params[:id])
  end

  def team_params
    params.require(:team).permit(:name)
  end
end
