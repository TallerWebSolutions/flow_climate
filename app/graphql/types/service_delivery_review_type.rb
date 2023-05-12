# frozen_string_literal: true

module Types
  class ServiceDeliveryReviewType < Types::BaseObject
    field :bugs_count, Int, null: false
    field :class_of_service_chart_data, [Types::Charts::SimpleChartType], null: true
    field :delayed_expedite_bottom_threshold, Float, null: false
    field :delayed_expedite_top_threshold, Float, null: false
    field :demands_count, Int, null: false
    field :demands_lead_time_p80, Float, null: false
    field :discarded_count, Int, null: false
    field :expedite_max_pull_time_sla, Int, null: false
    field :flow_events_chart_data, [Types::Charts::SimpleChartType], null: true
    field :id, ID, null: false
    field :lead_time_bottom_threshold, Float, null: false
    field :lead_time_top_threshold, Float, null: false
    field :longest_stage, Types::StageType, null: true
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

    def flow_events_chart_data
      min_date = object.demands.filter_map(&:end_date).min
      flow_events = object.product.flow_events.where('event_date BETWEEN :start_date AND :end_date', start_date: min_date, end_date: object.meeting_date)

      flow_events = flow_events.order(:event_type).select('flow_events.event_type, COUNT(flow_events.id) AS qty').group(:event_type)

      flow_events.map { |events_grouped| { label: I18n.t("activerecord.attributes.flow_event.enums.event_type.#{events_grouped[:event_type]}"), value: events_grouped[:qty] } }
    end

    def class_of_service_chart_data
      cos_chart_data = object.demands.order(:class_of_service).select('demands.class_of_service, COUNT(demands.id) AS qty').group(:class_of_service)

      cos_chart_data.map { |demands_grouped| { label: I18n.t("activerecord.attributes.demand.enums.class_of_service.#{demands_grouped[:class_of_service]}"), value: demands_grouped[:qty] } }
    end
  end
end
