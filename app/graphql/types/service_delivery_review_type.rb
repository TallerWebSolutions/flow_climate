# frozen_string_literal: true

module Types
  class ServiceDeliveryReviewType < Types::BaseObject
    field :bugs_count, Int, null: false
    field :delayed_expedite_bottom_threshold, Float, null: false
    field :delayed_expedite_top_threshold, Float, null: false
    field :demands_count, Int, null: false
    field :demands_lead_time_p80, Float, null: false
    field :discarded_count, Int, null: false
    field :expedite_max_pull_time_sla, Int, null: false
    field :id, ID, null: false
    field :lead_time_bottom_threshold, Float, null: false
    field :lead_time_top_threshold, Float, null: false
    field :longest_stage_name, String, null: false
    field :longest_stage_time, String, null: false
    field :meeting_date, GraphQL::Types::ISO8601Date, null: false
    field :product, Types::ProductType, null: false
    field :quality_bottom_threshold, Float, null: false
    field :quality_top_threshold, Float, null: false
    field :service_delivery_review_action_items, [Types::ServiceDeliveryReviewActionItemType], null: true

    def bugs_count
      object.demands.bug.count
    end

    def demands_count
      object.demands.count
    end

    def discarded_count
      object.demands.discarded.count
    end

    def longest_stage_name
      object.longest_stage[:name]
    end

    def longest_stage_time
      object.longest_stage[:time_in_stage]
    end
  end
end
