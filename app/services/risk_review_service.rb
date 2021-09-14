# frozen_string_literal: true

class RiskReviewService
  include Singleton

  def associate_demands_data(product, risk_review)
    demands = product.demands.kept.opened_before_date(risk_review.meeting_date.end_of_day).where('demands.risk_review_id' => nil)
    demands.map { |demand| demand.update(risk_review: risk_review) }

    demands = Demand.where(risk_review: risk_review)

    update_blocks(product, risk_review)
    update_flow_impacts(product, risk_review)

    update_block_avg_time(demands, risk_review)
  end

  private

  def update_block_avg_time(demands, risk_review)
    start_date = demands.filter_map(&:end_date).min
    array_of_dates = TimeService.instance.weeks_between_of(start_date, risk_review.meeting_date)

    risk_review.update(weekly_avg_blocked_time: build_avg_blocked_time(risk_review, array_of_dates))

    array_of_dates = TimeService.instance.months_between_of(start_date, risk_review.meeting_date)
    risk_review.update(monthly_avg_blocked_time: build_avg_blocked_time(risk_review, array_of_dates))
  end

  def update_flow_impacts(product, risk_review)
    flow_impacts = product.flow_impacts.kept.where('flow_impacts.risk_review_id' => nil)
    flow_impacts.map { |impact| impact.update(risk_review: risk_review) }
  end

  def update_blocks(product, risk_review)
    demand_blocks = product.demand_blocks.kept.where('demand_blocks.unblock_time <= :end_date AND demand_blocks.risk_review_id IS NULL', end_date: risk_review.meeting_date.end_of_day)
    demand_blocks.map { |block| block.update(risk_review: risk_review) if block.total_blocked_time > 1.hour }
  end

  def build_avg_blocked_time(risk_review, array_of_dates)
    avg_blocked_time = []
    array_of_dates.each do |date|
      blocks = risk_review.demand_blocks.where('unblock_time <= :limit_date', limit_date: date.end_of_day)
      avg_blocked_time << (blocks.filter_map(&:total_blocked_time).sum / blocks.map(&:demand).uniq.count)
    end

    avg_blocked_time
  end
end
