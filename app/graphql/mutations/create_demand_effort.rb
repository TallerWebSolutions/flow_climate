# frozen_string_literal: true

module Mutations
  class CreateDemandEffort < BaseMutation
    argument :demand_external_id, ID, required: true
    argument :demand_transition_id, ID, required: true
    argument :end_date, GraphQL::Types::ISO8601DateTime, required: true
    argument :item_assignment_id, ID, required: true
    argument :start_date, GraphQL::Types::ISO8601DateTime, required: true

    field :demand_effort, Types::DemandEffortType, null: true
    field :status_message, Types::CreateResponses, null: false

    def resolve(demand_external_id:, start_date:, end_date:, demand_transition_id:, item_assignment_id:)
      demand = Demand.find_by(external_id: demand_external_id)
      item_assignment = ItemAssignment.find_by(id: item_assignment_id)
      demand_transition = DemandTransition.find_by(id: demand_transition_id)

      return { status_message: 'NOT_FOUND' } if demand.blank? || item_assignment.blank? || demand_transition.blank?

      demand_effort = DemandEffort.create(demand: demand, demand_transition: demand_transition, item_assignment: item_assignment, start_time_to_computation: start_date, finish_time_to_computation: end_date, automatic_update: false)

      return { status_message: 'FAIL' } unless demand_effort.valid?

      { status_message: 'SUCCESS', demand_effort: demand_effort }
    end
  end
end
