# frozen_string_literal: true

class RiskReviewGeneratorJob < ApplicationJob
  queue_as :generators

  rescue_from(StandardError) do |exception|
    Rails.logger.error("[#{self.class.name}] #{exception}")
  end

  def perform(product, risk_review, user_name, user_email, risk_id, risk_review_url)
    started_time = Time.zone.now
    RiskReviewService.instance.associate_demands_data(product, risk_review)
    finished_time = Time.zone.now
    UserNotifierMailer.async_activity_finished(user_email, user_name, RiskReview.model_name.human.downcase, risk_id, started_time, finished_time, risk_review_url).deliver if user_email.present?
  end
end
