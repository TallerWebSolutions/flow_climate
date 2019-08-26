# frozen_string_literal: true

module Highchart
  class FinancesChartsAdapter
    attr_reader :finances

    def initialize(finances)
      @finances = finances.order(:finances_date)
    end

    def finances_hash_with_computed_informations
      return [] if @finances.empty?

      finances_data = []
      cost_per_hour_population = []
      expenses_population = []
      incomes_population = []

      @finances.each do |finance|
        finances_data << compute_finances_data(cost_per_hour_population, expenses_population, finances_data, finance.to_h, incomes_population)
      end

      finances_data
    end

    private

    def compute_finances_data(cost_per_hour_population, expenses_population, finances_data, finances_hash, incomes_population)
      finances_hash_with_computed_data = finances_hash.clone
      financial_information = FinancialInformation.find(finances_hash_with_computed_data['id'])

      incomes_population << finances_hash_with_computed_data['income_total']
      expenses_population << finances_hash_with_computed_data['expenses_total']
      finances_hash_with_computed_data['cost_per_hour'] = financial_information.cost_per_hour
      cost_per_hour_population << finances_hash_with_computed_data['cost_per_hour']

      finances_hash_with_computed_data = finances_hash_with_computed_data.merge(build_finances_hash(financial_information, incomes_population, expenses_population, cost_per_hour_population))
      finances_hash_with_computed_data['accumulated_financial_result'] = sum_finances_results(finances_data, finances_hash_with_computed_data)
      finances_hash_with_computed_data['finances_date'] = finances_hash_with_computed_data['finances_date']

      finances_hash_with_computed_data
    end

    def sum_finances_results(finances_data, finances_hash_with_computed_data)
      finances_data.sum { |array_of_hashes| array_of_hashes['financial_result'] } + finances_hash_with_computed_data['financial_result']
    end

    def build_finances_hash(financial_information, incomes_population, expenses_population, cost_per_hour_population)
      new_built_hash = {}

      new_built_hash['financial_result'] = financial_information.financial_result

      new_built_hash['project_delivered_hours'] = financial_information.project_delivered_hours
      new_built_hash['hours_per_demand'] = financial_information.hours_per_demand
      new_built_hash['income_per_hour'] = financial_information.income_per_hour
      new_built_hash['throughput_in_month'] = financial_information.throughput_in_month.count

      new_built_hash.merge(build_statistics_data(cost_per_hour_population, expenses_population, incomes_population))
    end

    def build_statistics_data(cost_per_hour_population, expenses_population, incomes_population)
      new_built_hash = {}
      new_built_hash['std_dev_cost_per_hour'] = Stats::StatisticsService.instance.standard_deviation(cost_per_hour_population)
      new_built_hash['mean_cost_per_hour'] = Stats::StatisticsService.instance.mean(cost_per_hour_population)
      new_built_hash['tail_events_after'] = Stats::StatisticsService.instance.tail_events_boundary(cost_per_hour_population)
      new_built_hash['std_dev_income'] = Stats::StatisticsService.instance.standard_deviation(incomes_population)
      new_built_hash['std_dev_expenses'] = Stats::StatisticsService.instance.standard_deviation(expenses_population)
      new_built_hash
    end
  end
end
