# frozen_string_literal: true

module Types
  class PortfolioUnitType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :parent, Types::PortfolioUnitType
    field :portfolio_unit_type, String
    field :total_cost, Float
    field :total_hours, Float
  end
end
