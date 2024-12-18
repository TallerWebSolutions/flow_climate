# frozen_string_literal: true

require 'csv'

class DemandEffortsController < AuthenticatedController
  before_action :assign_demand

  def index
    demand_efforts = DemandEffort.where(demand_id: @demand.id).order(start_time_to_computation: :desc)
    attributes = %w[demand_id start_time_to_computation finish_time_to_computation effort_value total_blocked management_percentage pairing_percentage stage_percentage main_effort_in_transition]
    efforts_csv = CSV.generate(headers: true) do |csv|
      csv << attributes
      demand_efforts.each { |effort| csv << effort.csv_array }
    end
    respond_to { |format| format.csv { send_data efforts_csv, filename: "demand-#{@demand.external_id}-efforts-#{Time.zone.now}.csv" } }
  end

  def new
    prepend_view_path Rails.public_path
    render 'spa-build/index'
  end

  def edit
    @demand_effort = DemandEffort.find(params[:id])
  end

  def update
    @demand_effort = DemandEffort.find(params[:id])

    @demand_effort.update(demand_effort_params.merge(automatic_update: false))

    call_cache_consolidations

    redirect_to company_demand_path(@company, @demand)
  end

  private

  def demand_effort_params
    params.require(:demand_effort).permit(:effort_value)
  end

  def call_cache_consolidations
    project = @demand.project
    team = @demand.team
    customer = @demand.customer || project.customers.first
    contract = @demand.contract || customer.contracts.active(@demand_effort.start_time_to_computation).first

    Consolidations::ProjectConsolidationJob.perform_later(project)
    Consolidations::TeamConsolidationJob.perform_later(team)
    Consolidations::CustomerConsolidationJob.perform_later(customer) if customer.present?
    Consolidations::ContractConsolidationJob.perform_later(contract) if contract.present?

    update_operations_dashboard_cache
  end

  def update_operations_dashboard_cache
    @demand.item_assignments.each do |assignment|
      member = assignment.membership.team_member
      start_date = @demand.demand_transitions.map(&:last_time_in).min
      end_date = @demand.demand_transitions.map(&:last_time_in).max

      Dashboards::OperationsDashboardCacheJob.perform_later(member, start_date, end_date)
    end
  end
end
