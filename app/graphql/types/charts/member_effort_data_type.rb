# frozen_string_literal: true

module Types
  module Charts
    class MemberEffortDataType < Types::BaseObject
      field :x_axis, [GraphQL::Types::ISO8601Date], null: true
      field :y_axis, [Float], null: true

      def x_axis
        object[:x_axis]
      end

      def y_axis
        object[:y_axis]
      end
    end
  end
end
