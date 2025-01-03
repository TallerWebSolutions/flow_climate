# frozen_string_literal: true

module Types
  class PortfolioUnitType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :parent, Types::PortfolioUnitType
    field :portfolio_unit_type_name, String
    field :total_cost, Float do
      argument :end_date, GraphQL::Types::ISO8601Date, required: false
      argument :start_date, GraphQL::Types::ISO8601Date, required: false
    end
    field :total_hours, Float do
      argument :end_date, GraphQL::Types::ISO8601Date, required: false
      argument :start_date, GraphQL::Types::ISO8601Date, required: false
    end

    def portfolio_unit_type_name
      I18n.t("activerecord.attributes.portfolio_unit.enums.portfolio_unit_type.#{object.portfolio_unit_type}")
    end

    def total_cost(start_date: nil, end_date: nil)
      object.total_cost(start_date, end_date)
    end

    def total_hours(start_date: nil, end_date: nil)
      object.total_hours(start_date, end_date)
    end
  end
end
