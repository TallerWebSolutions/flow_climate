# frozen_string_literal: true

module Types
  class PortfolioUnitType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :parent, Types::PortfolioUnitType
    field :portfolio_unit_type_name, String
    field :total_cost, Float
    field :total_hours, Float

    def portfolio_unit_type_name
      I18n.t("activerecord.attributes.portfolio_unit.enums.portfolio_unit_type.#{object.portfolio_unit_type}")
    end
  end
end
