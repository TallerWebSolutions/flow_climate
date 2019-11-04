# frozen_string_literal: true

module Flow
  class SystemFlowInformations
    attr_reader :demands, :demands_ids, :current_limit_date

    def initialize(demands)
      start_common_attributes

      return if demands.blank?

      @demands = demands.order('end_date, commitment_date, created_date')
      @demands_ids = @demands.map(&:id)
    end

    private

    def start_common_attributes
      @demands = []
      @demands_ids = []
      @current_limit_date = Time.zone.today.end_of_week
    end
  end
end
