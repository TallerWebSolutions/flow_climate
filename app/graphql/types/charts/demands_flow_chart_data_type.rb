# frozen_string_literal: true

module Types
  module Charts
    class DemandsFlowChartDataType < Types::BaseObject
      field :committed_chart_data, [Int], null: true
      field :creation_chart_data, [Int], null: true
      field :pull_transaction_rate, [Int], null: true
      field :throughput_chart_data, [Int], null: true
    end
  end
end
