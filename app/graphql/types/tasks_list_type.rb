# frozen_string_literal: true

module Types
  class TasksListType < Types::BaseObject
    field :total_count, Int, null: false
    field :total_delivered_count, Int, null: false

    field :tasks, [Types::TaskType], null: false
  end
end
