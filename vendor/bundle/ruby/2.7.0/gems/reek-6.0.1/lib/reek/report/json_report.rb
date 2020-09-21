# frozen_string_literal: true

require_relative 'base_report'

module Reek
  module Report
    #
    # Displays a list of smells in JSON format
    # JSON with empty array for 0 smells
    #
    # @public
    #
    class JSONReport < BaseReport
      def show(out = $stdout)
        out.print ::JSON.generate smells.map(&:yaml_hash)
      end
    end
  end
end
