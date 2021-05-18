# frozen_string_literal: true

module DemandsAggregator
  extend ActiveSupport::Concern

  def average_queue_time
    total_queue_time = demands.kept.sum(&:total_queue_time)
    total_demands = demands.kept.count

    return 0 if total_queue_time.zero? || total_demands.zero?

    total_queue_time.to_f / total_demands
  end

  def average_touch_time
    total_touch_time = demands.kept.sum(&:total_touch_time)
    total_demands = demands.kept.count

    return 0 if total_touch_time.zero? || total_demands.zero?

    total_touch_time.to_f / total_demands
  end

  def avg_hours_per_demand
    return 0 unless demands.kept.count.positive?

    demands.kept.filter_map(&:total_effort).sum / demands.kept.count
  end

  def upstream_demands
    demands.kept - demands.finished - demands.in_wip
  end
end
