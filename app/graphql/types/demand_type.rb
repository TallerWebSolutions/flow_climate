# frozen_string_literal: true

module Types
  class DemandType < Types::BaseObject
    field :commitment_date, GraphQL::Types::ISO8601DateTime, null: true
    field :company, Types::CompanyType, null: false
    field :cost_to_project, Float, null: true
    field :created_date, GraphQL::Types::ISO8601DateTime, null: true
    field :customer, Types::CustomerType, null: true
    field :demand_title, String, null: true
    field :demand_type, String, null: false
    field :effort_downstream, Float, null: true
    field :effort_upstream, Float, null: true
    field :end_date, GraphQL::Types::ISO8601DateTime, null: true
    field :external_id, String, null: false
    field :id, ID, null: false
    field :leadtime, Float, null: true
    field :number_of_blocks, Int, null: false
    field :product, Types::ProductType, null: true
    field :project, Types::ProjectType, null: false
    field :responsibles, [Types::TeamMemberType], null: true
    field :team, Types::TeamType, null: false

    def number_of_blocks
      object.demand_blocks.count
    end

    def responsibles
      object.active_memberships.map(&:team_member)
    end
  end
end
