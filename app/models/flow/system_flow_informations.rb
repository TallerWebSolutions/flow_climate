# frozen_string_literal: true

module Flow
  class SystemFlowInformations
    attr_reader :dates_array, :current_limit_date, :demands

    def initialize(dates_array, current_limit_date, demands)
      @dates_array = dates_array
      @current_limit_date = current_limit_date
      @demands = demands
      @demands_ids = demands.map(&:id)
    end
  end
end
