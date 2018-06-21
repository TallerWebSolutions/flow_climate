# frozen_string_literal: true

module Highchart
  class BurnupChartsAdapter < HighchartAdapter
    attr_reader :burnup_x_axis_period, :ideal_per_period, :current_per_period, :scope_per_period

    def initialize(period, scope_per_period, current_per_period)
      @burnup_x_axis_period = period
      @scope_per_period = scope_per_period
      @current_per_period = current_per_period
      @ideal_per_period = []
      ideal_burn
    end

    private

    def ideal_burn
      current_scope = scope_per_period.last
      period_size = @burnup_x_axis_period.count.to_f
      @burnup_x_axis_period.each_with_index { |_period, index| @ideal_per_period << (current_scope.to_f / period_size) * (index + 1) }
    end
  end
end
