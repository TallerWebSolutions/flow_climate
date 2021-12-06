# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :teams,
          [Types::TeamType],
          null: false,
          description: 'Set of teams'

    def teams
      Team.preload(:company)
    end
  end
end
