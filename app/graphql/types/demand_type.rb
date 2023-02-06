# frozen_string_literal: true

module Types
  class DemandType < Types::BaseObject
    field :commitment_date, GraphQL::Types::ISO8601DateTime, null: true
    field :company, Types::CompanyType, null: false
    field :cost_to_project, Float, null: true
    field :created_date, GraphQL::Types::ISO8601DateTime, null: true
    field :customer, Types::CustomerType, null: true
    field :customer_name, String, null: true
    field :demand_blocks_count, Int, null: false
    field :demand_efforts, [Types::DemandEffortType], null: true
    field :demand_title, String, null: true
    field :demand_type, String, null: false
    field :effort_downstream, Float, null: true
    field :effort_upstream, Float, null: true
    field :end_date, GraphQL::Types::ISO8601DateTime, null: true
    field :external_id, String, null: false
    field :id, ID, null: false
    field :leadtime, Float, null: true
    field :portfolio_unit, Types::PortfolioUnitType, null: true
    field :product, Types::ProductType, null: true
    field :product_name, String, null: true
    field :project, Types::ProjectType, null: false
    field :project_name, String, null: true
    field :responsibles, [Types::TeamMemberType], null: true
    field :team, Types::TeamType, null: false

    def responsibles
      object.memberships.map(&:team_member).uniq
    end
  end
end
