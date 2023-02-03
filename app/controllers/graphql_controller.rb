# frozen_string_literal: true

class GraphqlController < ApplicationController
  before_action :authenticate_spa

  def execute
    query = params[:query]
    operation_name = params[:operationName]
    
    result = FlowClimateSchema.execute(query, variables: params[:variables], context: @context, operation_name: operation_name)

    render json: result
  end

  private

  def authenticate_spa
    user_profile = request.headers['userprofile']

    if user_profile == "customer"
      authenticate_devise_customer!
      @context = {
        current_user: current_devise_customer
      }
    else
      authenticate_user!
      @context = {
        current_user: current_user
      }
    end

  end
end
