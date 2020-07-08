# frozen_string_literal: true

module Consolidations
  class ContractConsolidationJob < ApplicationJob
    queue_as :consolidations

    def perform(contract)
      contract_start = contract.start_date
      start_date = contract.start_date
      end_date = [contract.end_date, Time.zone.today.end_of_week].min

      while start_date <= end_date
        end_of_month = start_date.end_of_month

        demands = contract.demands.kept.where('demands.created_date <= :analysed_date', analysed_date: end_of_month)

        if demands.present?
          demands_chart_adapter = Highchart::DemandsChartsAdapter.new(demands, contract_start, end_of_month, 'week')

          contract_based_montecarlo_durations = Stats::StatisticsService.instance.run_montecarlo(contract.remaining_backlog(end_of_month), demands_chart_adapter.throughput_chart_data.last(10), 500)
          risk_to_date = 1 - Stats::StatisticsService.instance.compute_odds_to_deadline(contract.remaining_weeks(end_of_month), contract_based_montecarlo_durations)

          consolidation = ContractConsolidation.find_or_initialize_by(contract: contract, consolidation_date: end_of_month)
          consolidation.update(operational_risk_value: risk_to_date)
        else
          consolidation = ContractConsolidation.find_or_initialize_by(contract: contract, consolidation_date: end_of_month)
          consolidation.update(operational_risk_value: 1)
        end

        start_date += 1.month
      end
    end
  end
end
