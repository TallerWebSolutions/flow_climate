# frozen_string_literal: true

module Stats
  module Presenter
    class MonteCarloPresenter
      attr_accessor :dates_and_hits_hash, :predicted_dates, :monte_carlo_date_hash

      def initialize(dates_and_hits_hash)
        self.dates_and_hits_hash = dates_and_hits_hash
        self.predicted_dates = dates_and_hits_hash.sort_by { |_predicted_date, hits| hits }.reverse

        build_monte_carlo_date_hash
      end

      private

      def build_monte_carlo_date_hash
        monte_carlo_date_hash = {}
        hits_sum = dates_and_hits_hash.sum { |_predicted_date, hits| hits }
        predicted_dates.sort_by { |predicted_date, _hits| predicted_date }.each do |predicted_date|
          monte_carlo_date_hash[predicted_date[0]] = predicted_date[1].to_d / hits_sum
        end
        self.monte_carlo_date_hash = monte_carlo_date_hash
      end
    end
  end
end
