# frozen_string_literal: true

class DemandBlocksController < AuthenticatedController
  before_action :assign_company
  before_action :assign_project
  before_action :assign_demand, except: :index
  before_action :assign_demand_block, except: :index

  def activate
    @demand_block.activate!
    redirect_to company_project_demand_path(@company, @project, @demand)
  end

  def deactivate
    @demand_block.deactivate!
    redirect_to company_project_demand_path(@company, @project, @demand)
  end

  def edit
    respond_to { |format| format.js }
  end

  def update
    @demand_block.update(demand_block_params)
    render 'demand_blocks/update'
  end

  def index
    respond_to { |format| format.js }
  end

  private

  def demand_block_params
    params.require(:demand_block).permit(:block_type, :unblock_reason, :block_reason)
  end

  def assign_project
    @project = Project.find(params[:project_id])
  end

  def assign_demand
    @demand = Demand.find(params[:demand_id])
  end

  def assign_demand_block
    @demand_block = DemandBlock.find(params[:id])
  end
end
