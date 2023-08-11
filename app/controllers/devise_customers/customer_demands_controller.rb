# frozen_string_literal: true

module DeviseCustomers
  class CustomerDemandsController < ApplicationController
    before_action :authenticate_devise_customer!

    def show
      prepend_view_path Rails.public_path
      render 'spa-build/index'
    end

    def demand_efforts
      prepend_view_path Rails.public_path
      render 'spa-build/index'
    end
  end
end
