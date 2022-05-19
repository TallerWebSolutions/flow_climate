# frozen_string_literal: true

module Types
  module Charts
    class ProjectHoursChartDataType < Types::BaseObject
      field :x_axis, [GraphQL::Types::ISO8601Date], null: true
      field :y_axis_projects_names, [String], null: true
      field :y_axis_hours, [Float], null: true

      def x_axis
        object[:x_axis]
      end

      def y_axis_projects_names
        object[:y_axis_projects_names]
      end

      def y_axis_hours
        object[:y_axis_hours]
      end
    end
  end
end
