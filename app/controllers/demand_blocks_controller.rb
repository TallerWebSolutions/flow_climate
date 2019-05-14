# frozen_string_literal: true

class DemandBlocksController < AuthenticatedController
  before_action :user_gold_check
  before_action :assign_company
  before_action :assign_project, except: %i[index demands_blocks_tab demands_blocks_csv]
  before_action :assign_demand, except: %i[index demands_blocks_tab demands_blocks_csv]
  before_action :assign_demand_block, except: %i[index demands_blocks_tab demands_blocks_csv]
  before_action :assign_projects, only: %i[index demands_blocks_tab demands_blocks_csv]

  def activate
    @demand_block.activate!
    redirect_to company_demand_path(@company, @demand)
  end

  def deactivate
    @demand_block.deactivate!
    redirect_to company_demand_path(@company, @demand)
  end

  def edit
    respond_to { |format| format.js }
  end

  def update
    @demand_block.update(demand_block_params)
    render 'demand_blocks/update'
  end

  def index
    @demand_blocks = DemandBlocksRepository.instance.active_blocks_to_projects_and_period(@projects, start_date_to_query, end_date_to_query).order(block_time: :desc)
    respond_to { |format| format.js }
  end

  def demands_blocks_tab
    @demands_blocks = DemandBlocksRepository.instance.active_blocks_to_projects_and_period(@projects, start_date_to_query, end_date_to_query).order(block_time: :desc)

    respond_to { |format| format.js { render 'demand_blocks/demands_blocks_tab' } }
  end

  def demands_blocks_csv
    @demands_blocks = DemandBlocksRepository.instance.active_blocks_to_projects_and_period(@projects, start_date_to_query, end_date_to_query).order(block_time: :desc)

    attributes = %w[id block_time unblock_time block_duration demand_id]
    blocks_csv = CSV.generate(headers: true) do |csv|
      csv << attributes
      @demands_blocks.each { |block| csv << block.csv_array }
    end
    respond_to { |format| format.csv { send_data blocks_csv, filename: "demands-blocks-#{Time.zone.now}.csv" } }
  end

  private

  def assign_projects
    @projects = Project.where(id: params[:projects_ids].split(','))
  end

  def demand_block_params
    params.require(:demand_block).permit(:block_type, :unblock_reason)
  end

  def assign_project
    @project = Project.find(params[:project_id])
  end

  def assign_demand
    @demand = Demand.friendly.find(params[:demand_id])
  end

  def assign_demand_block
    @demand_block = DemandBlock.find(params[:id])
  end

  def start_date_to_query
    (params['start_date'] || @projects.map(&:start_date).min).to_date
  end

  def end_date_to_query
    (params['end_date'] || @projects.map(&:end_date).max).to_date
  end
end
