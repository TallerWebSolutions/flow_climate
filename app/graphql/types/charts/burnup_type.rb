# frozen_string_literal: true

module Types
  module Charts
    class BurnupType < Types::BaseObject
      field :project_tasks_ideal, [Float], null: true
      field :project_tasks_scope, [Int], null: true
      field :project_tasks_throughtput, [Int], null: true
      field :x_axis, [GraphQL::Types::ISO8601Date], null: true
    end
  end
end
