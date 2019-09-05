# frozen_string_literal: true

class RiskReviewService
  include Singleton

  def associate_demands_data(product, risk_review)
    demands = product.demands.where('demands.end_date <= :end_date AND demands.risk_review_id IS NULL', end_date: risk_review.meeting_date.end_of_day)
    demands.map { |demand| demand.update(risk_review: risk_review) }

    demand_blocks = product.demand_blocks.where('demand_blocks.unblock_time <= :end_date AND demand_blocks.risk_review_id IS NULL', end_date: risk_review.meeting_date.end_of_day)
    demand_blocks.map { |block| block.update(risk_review: risk_review) }

    flow_impacts = product.flow_impacts.where('flow_impacts.start_date <= :end_date AND flow_impacts.risk_review_id IS NULL', end_date: risk_review.meeting_date.end_of_day)
    flow_impacts.map { |impact| impact.update(risk_review: risk_review) }
  end
end
