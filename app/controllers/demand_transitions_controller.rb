# frozen_string_literal: true

class DemandTransitionsController < AuthenticatedController
  before_action :user_gold_check

  before_action :assign_stage, except: %i[new create edit update]
  before_action :assign_demand, except: :destroy
  before_action :assign_demand_transition, except: %i[new create]

  def new
    @demand_transition = DemandTransition.new(demand: @demand)
    demand_transitions
    stages_to_select

    respond_to { |format| format.js { render 'demand_transitions/new' } }
  end

  def edit
    demand_transitions
    stages_to_select

    respond_to { |format| format.js { render 'demand_transitions/edit' } }
  end

  def create
    @demand_transition = DemandTransition.create(demand_transition_params.merge(demand: @demand))
    demand_transitions
    stages_to_select

    respond_to { |format| format.js { render 'demand_transitions/create' } }
  end

  def update
    @demand_transition.update(demand_transition_params)
    demand_transitions
    stages_to_select

    respond_to { |format| format.js { render 'demand_transitions/update' } }
  end

  def destroy
    @demand_transition.destroy

    redirect_to company_stage_path(@company, @stage)
  end

  private

  def stages_to_select
    @stages_to_select ||= @company.stages.joins(:teams).where(teams: { id: @demand.team.id }).order(:order)
  end

  def demand_transition_params
    params.require(:demand_transition).permit(:stage_id, :last_time_in, :last_time_out)
  end

  def assign_stage
    @stage = Stage.find(params[:stage_id])
  end

  def assign_demand_transition
    @demand_transition = DemandTransition.find(params[:id])
  end

  def demand_transitions
    @demand_transitions ||= @demand.demand_transitions.order(:last_time_in)
  end
end
