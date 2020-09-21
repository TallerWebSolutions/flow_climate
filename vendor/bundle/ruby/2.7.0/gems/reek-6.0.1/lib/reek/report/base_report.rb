# frozen_string_literal: true

require 'json'
require 'pathname'
require 'rainbow'

module Reek
  # @public
  module Report
    #
    # A report that contains the smells and smell counts following source code analysis.
    #
    # @abstract Subclass and override {#show} to create a concrete report class.
    #
    # @public
    #
    # @quality :reek:TooManyInstanceVariables { max_instance_variables: 7 }
    class BaseReport
      NO_WARNINGS_COLOR = :green
      WARNINGS_COLOR = :red

      # @public
      #
      # @quality :reek:BooleanParameter
      def initialize(heading_formatter: QuietHeadingFormatter,
                     sort_by_issue_count: false,
                     warning_formatter: SimpleWarningFormatter.new,
                     progress_formatter: ProgressFormatter::Quiet.new(0))
        @examiners           = []
        @heading_formatter   = heading_formatter.new
        @progress_formatter  = progress_formatter
        @sort_by_issue_count = sort_by_issue_count
        @total_smell_count   = 0
        @warning_formatter   = warning_formatter
      end

      # Add Examiner to report on. The report will output results for all
      # added examiners.
      #
      # @param [Reek::Examiner] examiner object to report on
      #
      # @public
      def add_examiner(examiner)
        self.total_smell_count += examiner.smells_count
        examiners << examiner
        self
      end

      # Render the report results on STDOUT
      #
      # @public
      def show
        raise NotImplementedError
      end

      def smells?
        total_smell_count.positive?
      end

      def smells
        examiners.map(&:smells).flatten
      end

      protected

      attr_accessor :total_smell_count

      private

      attr_reader :examiners, :heading_formatter,
                  :sort_by_issue_count, :warning_formatter, :progress_formatter
    end
  end
end
