# frozen_string_literal: true

class RiskReviewService
  include Singleton

  def associate_demands_data(product, risk_review)
    demands = product.demands.kept.opened_before_date(risk_review.meeting_date.end_of_day).where('demands.risk_review_id IS NULL')
    demands.map { |demand| demand.update(risk_review: risk_review) }

    update_blocks(product, risk_review)
    update_flow_impacts(product, risk_review)
  end

  private

  def update_flow_impacts(product, risk_review)
    flow_impacts = product.flow_impacts.kept.where('flow_impacts.start_date <= :end_date AND flow_impacts.risk_review_id IS NULL', end_date: risk_review.meeting_date.end_of_day)
    flow_impacts.map { |impact| impact.update(risk_review: risk_review) }
  end

  def update_blocks(product, risk_review)
    demand_blocks = product.demand_blocks.kept.where('demand_blocks.unblock_time <= :end_date AND demand_blocks.risk_review_id IS NULL', end_date: risk_review.meeting_date.end_of_day)
    demand_blocks.map { |block| block.update(risk_review: risk_review) }
  end
end
