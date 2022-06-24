# frozen_string_literal: true

module Types
  module Charts
    class ControlChartType < Types::BaseObject
      field :lead_times, [Float], null: false
      field :x_axis, [String], null: false

      field :lead_time_p65, Float, null: false
      field :lead_time_p80, Float, null: false
      field :lead_time_p95, Float, null: false
    end
  end
end
