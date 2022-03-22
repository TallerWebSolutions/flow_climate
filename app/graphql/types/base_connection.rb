# frozen_string_literal: true

module Types
  class BaseConnection < Types::BaseObject
    include GraphQL::Types::Relay::ConnectionBehaviors

    field :total_count, Integer, null: false
    def total_count
      object.items&.count
    end

    field :total_finished_tasks_count, Integer, null: false
    def total_finished_tasks_count
      object.items&.finished&.count
    end
  end
end
