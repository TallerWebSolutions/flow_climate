# frozen_string_literal: true

module Types
  module Charts
    class LeadTimeHistogramDataType < Types::BaseObject
      field :keys, [Float], null: true
      field :values, [Int], null: true

      delegate :keys, to: :object

      delegate :values, to: :object
    end
  end
end
