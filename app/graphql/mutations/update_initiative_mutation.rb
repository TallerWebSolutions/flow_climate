# frozen_string_literal: true

module Mutations
  class UpdateInitiativeMutation < Mutations::BaseMutation
    argument :initiative_id, ID, required: true
    argument :name, String, required: true
    argument :end_date, GraphQL::Types::ISO8601Date, required: true
    argument :start_date, GraphQL::Types::ISO8601Date, required: true
    argument :target_quarter, Types::Enums::TargetQuarter, required: true
    argument :target_year, Int, required: true

    field :initiative, Types::InitiativeType, null: true
    field :status_message, Types::UpdateResponses, null: false

    def resolve(initiative_id:, name:, end_date:, start_date:, target_quarter:, target_year:)
      initiative = Initiative.find(initiative_id)

      if initiative.update(name: name, end_date: end_date, start_date: start_date, target_quarter: target_quarter, target_year: target_year)
        { status_message: 'SUCCESS', initiative: initiative }
      else
        { status_message: 'FAIL' }
      end
    end
  end
end
