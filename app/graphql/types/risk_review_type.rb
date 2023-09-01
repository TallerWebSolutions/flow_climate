# frozen_string_literal: true

module Types
  class RiskReviewType < Types::BaseObject
    field :company, Types::CompanyType, null: false
    field :demands_count, Integer
    field :demands_lead_time_p80, Float
    field :outlier_demands_count, Integer
    field :outlier_demands_percentage, Float
    field :bugs_count, Integer
    field :bug_percentage, Float
    field :demands, [Types::DemandType]
    field :blocks_per_demand, Float
    field :flow_events_count, Integer
    field :events_per_demand, Float
    field :project_broken_wip_count, Integer
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :id, ID, null: false
    field :lead_time_outlier_limit, Float, null: false
    field :meeting_date, GraphQL::Types::ISO8601Date, null: false
    field :monthly_avg_blocked_time, [Float]
    field :product, Types::ProductType, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :weekly_avg_blocked_time, [Float]
  end
end
