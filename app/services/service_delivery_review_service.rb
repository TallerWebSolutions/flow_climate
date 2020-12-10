# frozen_string_literal: true

class ServiceDeliveryReviewService
  include Singleton

  def associate_demands_data(product, service_delivery_review)
    demands = build_demands(product, service_delivery_review)
    demands = Demand.where(id: demands.map(&:id))
    demands.map { |demand| demand.update(service_delivery_review: service_delivery_review) }

    bugs_opened_in_period = product.demands.kept.bug.where('created_date BETWEEN :start_date AND :end_date', start_date: demands.finished.map(&:end_date).min, end_date: service_delivery_review.meeting_date)
    service_delivery_review.update(bugs_ids: bugs_opened_in_period.map(&:id))
  end

  private

  def build_demands(product, service_delivery_review)
    demands = product.demands.where('demands.end_date <= :limit_date AND demands.service_delivery_review_id IS NULL', limit_date: service_delivery_review.meeting_date.end_of_day)
    demands + product.demands.where('demands.discarded_at <= :limit_date', limit_date: service_delivery_review.meeting_date.end_of_day)
  end
end
