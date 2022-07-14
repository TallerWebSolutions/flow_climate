# frozen_string_literal: true

module Types
  module Charts
    class BurnupType < Types::BaseObject
      field :current_burn, [Int], null: true
      field :ideal_burn, [Float], null: true
      field :scope, [Int], null: true
      field :x_axis, [GraphQL::Types::ISO8601Date], null: true
    end
  end
end
