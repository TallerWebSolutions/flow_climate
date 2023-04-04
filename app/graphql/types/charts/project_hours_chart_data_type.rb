# frozen_string_literal: true

module Types
  module Charts
    class ProjectHoursChartDataType < Types::BaseObject
      field :x_axis, [GraphQL::Types::ISO8601Date], null: true
      field :y_axis_hours, [Float], null: true
      field :y_axis_projects_names, [String], null: true
    end
  end
end
