# frozen_string_literal: true

module Types
  module Charts
    class SimpleChartType < Types::BaseObject
      field :label, String, null: false
      field :value, Int, null: false
    end
  end
end
