# frozen_string_literal: true

module Types
  module Charts
    class LeadTimeHistogramDataType < Types::BaseObject
      field :keys, [Float], null: true
      field :values, [Int], null: true

      def keys
        object.keys
      end

      def values
        object.values
      end
    end
  end
end
