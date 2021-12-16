# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :teams,
          [Types::TeamType],
          null: true,
          description: 'Set of teams'

    field :team,
          Types::TeamType,
          null: true,
          description: 'A team with consolidations' do
      argument :id, Int
    end

    field :me, Types::UserType, null: false

    def teams
      Team.preload(:company)
    end

    def team(id:)
      Team.find(id)
    end

    def me
      context[:current_user]
    end
  end
end
