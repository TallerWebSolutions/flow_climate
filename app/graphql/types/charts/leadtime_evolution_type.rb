# frozen_string_literal: true

module Types
  module Charts
    class LeadtimeEvolutionType < Types::BaseObject
      field :x_axis, [String], null: false
      field :y_axis_accumulated, [Float], null: false
      field :y_axis_in_month, [Float], null: false
    end
  end
end
