# frozen_string_literal: true

class DemandEffortsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_demand

  def index
    demand_efforts = DemandEffort.where(demand_id: @demand.id).order(start_time_to_computation: :desc)
    attributes = %w[demand_id start_time_to_computation finish_time_to_computation effort_value effort_with_blocks total_blocked management_percentage pairing_percentage stage_percentage main_effort_in_transition]
    efforts_csv = CSV.generate(headers: true) do |csv|
      csv << attributes
      demand_efforts.each { |effort| csv << effort.csv_array }
    end
    respond_to { |format| format.csv { send_data efforts_csv, filename: "demand-#{@demand.external_id}-efforts-#{Time.zone.now}.csv" } }
  end
end
