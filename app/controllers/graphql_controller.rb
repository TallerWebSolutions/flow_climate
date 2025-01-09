# frozen_string_literal: true

class GraphqlController < ApplicationController
  include Authentication

  allow_unauthenticated_access only: %i[execute]
  before_action :authenticate_spa

  def execute
    query = params[:query]
    operation_name = params[:operationName]

    result = FlowClimateSchema.execute(query, variables: params[:variables], context: @context, operation_name: operation_name)

    render json: result
  end

  private

  def authenticate_spa
    require_authentication
    @context = {
      current_user: Current.user
    }
  end
end
