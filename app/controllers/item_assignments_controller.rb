# frozen-string-literal: true

class ItemAssignmentsController < AuthenticatedController
  before_action :assign_company

  def destroy
    @demand = @company.demands.find(params[:demand_id])
    @item_assignment = @demand.item_assignments.find(params[:id])

    @item_assignment.destroy

    respond_to { |format| format.js { render 'item_assignments/destroy' } }
  end
end
