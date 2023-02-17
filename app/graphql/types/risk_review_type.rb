# frozen_string_literal: true

module Types
  class RiskReviewType < Types::BaseObject
    field :company, Types::CompanyType, null: false
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
