# frozen_string_literal: true

class DemandEffortsController < AuthenticatedController
  before_action :assign_demand
  before_action :assign_demand_effort, only: %i[edit update]

  def index
    demand_efforts = DemandEffort.where(demand_id: @demand.id).order(start_time_to_computation: :desc)
    attributes = %w[demand_id start_time_to_computation finish_time_to_computation effort_value effort_with_blocks total_blocked management_percentage pairing_percentage stage_percentage main_effort_in_transition]
    efforts_csv = CSV.generate(headers: true) do |csv|
      csv << attributes
      demand_efforts.each { |effort| csv << effort.csv_array }
    end
    respond_to { |format| format.csv { send_data efforts_csv, filename: "demand-#{@demand.external_id}-efforts-#{Time.zone.now}.csv" } }
  end

  def edit; end

  def update
    @demand_effort.update(effort_params.merge(automatic_update: false, effort_with_blocks: BigDecimal(params[:demand_effort][:effort_value].to_s)))
    DemandEffortService.instance.build_efforts_to_demand(@demand_effort.demand)
    redirect_to company_demand_path(@company, @demand)
  end

  private

  def effort_params
    params.require(:demand_effort).permit(:effort_value)
  end

  def assign_demand_effort
    @demand_effort = DemandEffort.find(params[:id])
  end
end
