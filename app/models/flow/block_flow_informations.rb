# frozen_string_literal: true

module Flow
  class BlockFlowInformations < SystemFlowInformations
    attr_reader :blocks_count, :blocks_time

    def initialize(dates_array, current_limit_date, demands)
      super(dates_array, current_limit_date, demands)

      @blocks_count = []
      @blocks_time = []

      blocks_flow_behaviour
    end

    def blocks_flow_behaviour
      @dates_array.each do |date|
        next if @current_limit_date < date

        demands_finished_until_date = @demands.finished_until_date(date) # query

        build_block_flow_info(demands_finished_until_date)
      end
    end

    def build_block_flow_info(demands_finished_until_date)
      block_time = demands_finished_until_date.sum(&:blocked_time).to_f / 1.hour
      block_count = demands_finished_until_date.sum(&:demand_blocks_count)

      @blocks_time << block_time - @blocks_time.sum
      @blocks_count << block_count - @blocks_count.sum
    end
  end
end
