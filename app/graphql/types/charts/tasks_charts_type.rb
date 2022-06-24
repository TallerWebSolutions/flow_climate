# frozen-string-literal: true

module Types
  module Charts
    class TasksChartsType < Types::BaseObject
      field :accumulated_completion_percentiles_on_time_array, [Float], null: false
      field :completion_percentiles_on_time_array, [Float], null: false
      field :creation_array, [Int], null: false
      field :throughput_array, [Int], null: false
      field :x_axis, [GraphQL::Types::ISO8601Date], null: false
    end
  end
end
