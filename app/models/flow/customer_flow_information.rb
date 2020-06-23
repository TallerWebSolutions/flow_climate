# frozen_string_literal: true

module Flow
  class CustomerFlowInformation < SystemFlowInformation
    attr_reader :financial_burnup, :data_interval, :dates_array

    def initialize(customer, data_interval = 'month')
      super(customer.demands)

      @financial_burnup = {}
      @data_interval = data_interval
    end

    def build_financial_burnup

    end
  end
end
