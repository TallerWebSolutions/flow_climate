# frozen_string_literal: true

namespace :fixer do
  desc 'fix problem with discarded demands in SDRs'
  task fix_discarded_in_sdrs: :environment do
    ServiceDeliveryReview.all.order(:meeting_date).each do |sdr|
      ServiceDeliveryReviewService.instance.associate_demands_data(sdr.product, sdr)
    end
  end
end
