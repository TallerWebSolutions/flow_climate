# frozen_string_literal: true

class AddOpenedBugsIdsToServiceDeliveryReview < ActiveRecord::Migration[6.0]
  def change
    add_column :service_delivery_reviews, :bugs_ids, :integer, array: true
  end
end
