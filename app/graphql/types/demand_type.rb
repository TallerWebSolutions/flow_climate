# frozen_string_literal: true

module Types
  class DemandType < Types::BaseObject
    field :class_of_service, String
    field :commitment_date, GraphQL::Types::ISO8601DateTime, null: true
    field :company, Types::CompanyType, null: false
    field :cost_to_project, Float, null: true
    field :created_date, GraphQL::Types::ISO8601DateTime, null: true
    field :current_stage_name, String
    field :customer, Types::CustomerType, null: true
    field :customer_name, String, null: true
    field :demand_blocks_count, Int, null: false
    field :demand_efforts, [Types::DemandEffortType], null: true
    field :demand_score, Float, null: false
    field :demand_score_matrices, [Types::DemandScoreMatrixType], null: true
    field :demand_title, String, null: true
    field :demand_transitions, [Types::DemandTransitionType], null: true
    field :demand_type, String, null: false
    field :discarded_at, GraphQL::Types::ISO8601DateTime, null: true
    field :effort_downstream, Float, null: true
    field :effort_upstream, Float, null: true
    field :end_date, GraphQL::Types::ISO8601DateTime, null: true
    field :external_id, String, null: false
    field :id, ID, null: false
    field :item_assignments, [Types::ItemAssignmentType], null: true
    field :leadtime, Float, null: true
    field :portfolio_unit, Types::PortfolioUnitType, null: true
    field :portfolio_unit_name, String
    field :product, Types::ProductType, null: true
    field :product_name, String, null: true
    field :project, Types::ProjectType, null: false
    field :project_name, String, null: true
    field :responsibles, [Types::Teams::TeamMemberType], null: true
    field :team, Types::Teams::TeamType, null: false

    def demand_efforts
      object.demand_efforts.order(start_time_to_computation: :asc)
    end

    def responsibles
      object.memberships.map(&:team_member).uniq
    end

    def item_assignments
      object.item_assignments.where(id: object.item_assignments.group(:membership_id).maximum(:id).values)
    end
  end
end
