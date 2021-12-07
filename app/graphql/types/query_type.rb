# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :teams,
          [Types::TeamType],
          null: false,
          description: 'Set of teams'

    field :team,
          Types::TeamType,
          null: false,
          description: 'A team with consolidations' do
      argument :id, Int
    end

    def teams
      Team.preload(:company)
    end

    def team(id:)
      Team.find(id)
    end
  end
end
