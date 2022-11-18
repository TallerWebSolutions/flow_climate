# frozen_string_literal: true

module DeviseCustomers
  class ContractsController < ApplicationController
    before_action :authenticate_devise_customer!

    def show
      @contract = Contract.find(params[:id])
      @contracts_flow_information = Flow::ContractsFlowInformation.new(@contract)
    end
  end
end
