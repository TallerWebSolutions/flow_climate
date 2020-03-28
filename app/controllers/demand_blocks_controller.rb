# frozen_string_literal: true

class DemandBlocksController < AuthenticatedController
  before_action :user_gold_check
  before_action :assign_company
  before_action :assign_project, except: %i[index demand_blocks_tab demand_blocks_csv search]
  before_action :assign_demand, except: %i[index demand_blocks_tab demand_blocks_csv search]
  before_action :assign_demand_block, except: %i[index demand_blocks_tab demand_blocks_csv search]
  before_action :assign_projects, only: %i[index demand_blocks_tab]

  def activate
    @demand_block.activate!
    render 'demand_blocks/activate_deactivate_block'
  end

  def deactivate
    @demand_block.deactivate!
    render 'demand_blocks/activate_deactivate_block'
  end

  def edit
    render 'demand_blocks/edit'
  end

  def update
    @demand_block.update(demand_block_params)
    render 'demand_blocks/update'
  end

  def index
    @demand_blocks = DemandBlocksRepository.instance.active_blocks_to_projects_and_period(@projects, 3.months.ago, end_date_to_query).order(block_time: :desc)
    render 'demand_blocks/index'
  end

  def demand_blocks_tab
    @demand_blocks = DemandBlocksRepository.instance.active_blocks_to_projects_and_period(@projects, 3.months.ago, end_date_to_query).order(block_time: :desc)

    respond_to { |format| format.js { 'demand_blocks/demand_blocks_tab' } }
  end

  def demand_blocks_csv
    @demand_blocks_ids = params[:demand_blocks_ids]
    @demand_blocks = DemandBlock.where(id: @demand_blocks_ids)

    attributes = %w[id block_time unblock_time block_working_time_duration external_id]
    blocks_csv = CSV.generate(headers: true) do |csv|
      csv << attributes
      @demand_blocks.each { |block| csv << block.csv_array }
    end
    respond_to { |format| format.csv { send_data blocks_csv, filename: "demands-blocks-#{Time.zone.now}.csv" } }
  end

  def search
    @demand_blocks_ids = params[:demand_blocks_ids].split(',')
    @demand_blocks = DemandBlock.where(id: @demand_blocks_ids.map(&:to_i))
    @demand_blocks = build_date_query(@demand_blocks)
    @demand_blocks = build_type_query(@demand_blocks)
    @demand_blocks = build_member_query(@demand_blocks)
    @demand_blocks = build_stage_query(@demand_blocks)
    @demand_blocks = build_ordering_query(@demand_blocks)

    respond_to { |format| format.js { render 'demand_blocks/search' } }
  end

  private

  def build_date_query(demand_blocks)
    return demand_blocks if params[:blocks_start_date].blank? || params[:blocks_end_date].blank?

    demand_blocks.where('(block_time BETWEEN :start_date AND :end_date) OR (unblock_time IS NOT NULL AND unblock_time BETWEEN :start_date AND :end_date)', start_date: params[:blocks_start_date].to_date.beginning_of_day, end_date: params[:blocks_end_date].to_date.end_of_day)
  end

  def build_type_query(demand_blocks)
    return demand_blocks if params[:blocks_type].blank?

    demand_blocks.where('block_type = :block_type', block_type: params[:blocks_type])
  end

  def build_member_query(demand_blocks)
    return demand_blocks if params[:blocks_team_member].blank?

    demand_blocks.where('(blocker_id = :member_id) OR (unblocker_id = :member_id)', member_id: params[:blocks_team_member])
  end

  def build_stage_query(demand_blocks)
    return demand_blocks if params[:blocks_stage].blank?

    demand_blocks.where(stage_id: params[:blocks_stage].to_i)
  end

  def build_ordering_query(demand_blocks)
    if params[:blocks_ordering] == 'member_name'
      DemandBlock.where(id: demand_blocks.sort_by(&:blocker_name).map(&:id))
    else
      demand_blocks.order(:block_time)
    end
  end

  def assign_projects
    @projects = Project.where(id: projects_ids)
  end

  def demand_block_params
    params.require(:demand_block).permit(:block_type, :block_reason, :blocker_id, :unblock_time, :unblocker_id)
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

  def end_date_to_query
    (params['end_date'] || Time.zone.today).to_date
  end
end
