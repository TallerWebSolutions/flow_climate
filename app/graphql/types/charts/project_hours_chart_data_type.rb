# frozen_string_literal: true

module Types
  module Charts
    class ProjectHoursChartDataType < Types::BaseObject
      field :x_axis, [GraphQL::Types::ISO8601Date], null: true, hash_key: :x_axis
      field :y_axis_hours, [Float], null: true, hash_key: :y_axis_hours
      field :y_axis_projects_names, [String], null: true, hash_key: :y_axis_projects_names
    end
  end
end
