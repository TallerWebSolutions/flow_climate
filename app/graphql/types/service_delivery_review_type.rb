# frozen_string_literal: true

module Types
  class ServiceDeliveryReviewType < Types::BaseObject
    field :company_id, ID, null: false
    field :delayed_expedite_bottom_threshold, Float, null: false
    field :delayed_expedite_top_threshold, Float, null: false
    field :expedite_max_pull_time_sla, Int, null: false
    field :id, ID, null: false
    field :lead_time_bottom_threshold, Float, null: false
    field :lead_time_top_threshold, Float, null: false
    field :meeting_date, GraphQL::Types::ISO8601Date, null: false
    field :product_id, ID, null: false
    field :quality_bottom_threshold, Float, null: false
    field :quality_top_threshold, Float, null: false
  end
end
