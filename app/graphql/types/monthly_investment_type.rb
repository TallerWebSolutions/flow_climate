# frozen_string_literal: true

module Types
  class MonthlyInvestmentType < Types::BaseObject
    field :x_axis, [GraphQL::Types::ISO8601Date], null: true
    field :y_axis, [Float], null: true
  end
end
