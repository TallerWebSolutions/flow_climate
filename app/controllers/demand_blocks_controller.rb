# frozen_string_literal: true

class DemandBlocksController < AuthenticatedController
  before_action :assign_company
  before_action :assign_project
  before_action :assign_demand
  before_action :assign_demand_block

  def activate
    @demand_block.activate!
    redirect_to company_project_demand_path(@company, @project, @demand)
  end

  def deactivate
    @demand_block.deactivate!
    redirect_to company_project_demand_path(@company, @project, @demand)
  end

  private

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
