# frozen_string_literal: true

class BurnupData < ChartData
  attr_reader :weeks, :ideal_per_week, :current_per_week, :scope_per_week

  def initialize(weeks, scope_per_week, current_per_week)
    @weeks = weeks
    @scope_per_week = scope_per_week
    @current_per_week = current_per_week
    @ideal_per_week = []
    ideal_burn
  end

  private

  def ideal_burn
    current_scope = scope_per_week.last
    weeks_size = @weeks.count.to_f
    @weeks.each_with_index { |_week_year, index| @ideal_per_week << (current_scope.to_f / weeks_size) * (index + 1) }
  end
end
