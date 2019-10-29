# frozen_string_literal: true

module Flow
  class BlockFlowInformations < SystemFlowInformations
    attr_reader :blocks_count, :blocks_time

    def initialize(demands)
      super(demands)

      @blocks_count = []
      @blocks_time = []
    end

    def blocks_flow_behaviour(analysed_date)
      return if @demands.blank?

      demands_finished_until_date = @demands.finished_until_date(analysed_date) # query

      build_block_flow_info(demands_finished_until_date)
    end

    private

    def build_block_flow_info(demands_finished_until_date)
      block_time = demands_finished_until_date.sum(&:blocked_time).to_f / 1.hour
      block_count = demands_finished_until_date.sum(&:demand_blocks_count)

      @blocks_time << block_time - @blocks_time.sum
      @blocks_count << block_count - @blocks_count.sum
    end
  end
end
