# frozen_string_literal: true

module Types
  module Charts
    class LeadTimeControlChartDataType < Types::BaseObject
      field :x_axis, [String], null: false
      field :y_axis, [Float], null: false
      field :lead_time_p65, Float, null: false
      field :lead_time_p80, Float, null: false
      field :lead_time_p95, Float, null: false
    end
  end
end
