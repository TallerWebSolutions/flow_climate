# frozen_string_literal: true

module Highchart
  class BurnupAdapter
    attr_reader :work_items, :start_date, :end_date, :x_axis, :ideal_burn, :current_burn, :scope

    def initialize(work_items, start_date, end_date)
      @work_items = work_items
      @start_date = start_date
      @end_date = end_date

      @x_axis = TimeService.instance.weeks_between_of(@start_date.end_of_week, @end_date.end_of_week)
      @ideal_burn = []
      @current_burn = []
      @scope = []

      build_burnup_data
    end

    private

    def build_burnup_data
      ideal_burn_per_week = @work_items.kept.count / @x_axis.count.to_f

      @x_axis.each_with_index do |date, index|
        @scope << @work_items.where('created_date <= :limit_date AND (discarded_at IS NULL OR discarded_at > :limit_date)', limit_date: date).count
        @ideal_burn << (ideal_burn_per_week * (index + 1))
        @current_burn << @work_items.where('end_date <= :limit_date AND (discarded_at IS NULL OR discarded_at > :limit_date)', limit_date: date).count if date <= Time.zone.now.end_of_week
      end
    end
  end
end
