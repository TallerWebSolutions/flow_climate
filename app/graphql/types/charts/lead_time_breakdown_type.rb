# frozen_string_literal: true

module Types
  module Charts
    class LeadTimeBreakdownType < Types::BaseObject
      field :x_axis, [String], null: false
      field :y_axis, [Float], null: false
    end
  end
end
