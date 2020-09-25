# frozen-string-literal: true

class ItemAssignmentsController < AuthenticatedController
  before_action :assign_company

  def destroy
    @item_assignment = ItemAssignment.find(params[:id])

    @item_assignment.destroy

    respond_to { |format| format.js { render 'item_assignments/destroy.js.erb' } }
  end
end
