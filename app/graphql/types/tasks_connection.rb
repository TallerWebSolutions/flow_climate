# frozen_string_literal: true

module Types
  class TasksConnection < BaseConnection
    include GraphQL::Types::Relay::ConnectionBehaviors

    field :total_finished_tasks_count, Integer, null: false
    def total_finished_tasks_count
      object.items&.finished&.count
    end
  end
end
