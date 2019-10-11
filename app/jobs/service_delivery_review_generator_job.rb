class ServiceDeliveryReviewGeneratorJob < ApplicationJob
  queue_as :default

  rescue_from(StandardError) do |exception|
    Rails.logger.error("[#{self.class.name}] #{exception}")
  end

  def perform(product, service_delivery_review, user_name, user_email, service_delivery_review_id, service_delivery_review_url)
    started_time = Time.zone.now
    ServiceDeliveryReviewService.instance.associate_demands_data(product, service_delivery_review)
    finished_time = Time.zone.now
    UserNotifierMailer.async_activity_finished(user_email, user_name, ServiceDeliveryReview.model_name.human.downcase, service_delivery_review_id, started_time, finished_time, service_delivery_review_url).deliver if user_email.present?
  end

end