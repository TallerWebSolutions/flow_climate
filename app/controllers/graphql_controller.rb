# frozen_string_literal: true

class GraphqlController < AuthenticatedController

  def execute
    query = params[:query]
    operation_name = params[:operationName]
    context = {
      # Query context goes here, for example:
      # current_user: current_user,
    }
    result = FlowClimateSchema.execute(query, variables: params[:variables], context: context, operation_name: operation_name)
    render json: result
  end
end
