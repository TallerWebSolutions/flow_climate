# frozen_string_literal: true

require_relative 'base_detector'

module Reek
  module SmellDetectors
    #
    # An Uncommunicative Name is a name that doesn't communicate its intent
    # well enough.
    #
    # Poor names make it hard for the reader to build a mental picture
    # of what's going on in the code. They can also be mis-interpreted;
    # and they hurt the flow of reading, because the reader must slow
    # down to interpret the names.
    #
    # Currently +UncommunicativeMethodName+ checks for
    # * 1-character names
    # * names ending with a number
    # * names containing a capital letter (assuming camelCase)
    #
    # See {file:docs/Uncommunicative-Method-Name.md} for details.
    class UncommunicativeMethodName < BaseDetector
      REJECT_KEY = 'reject'
      ACCEPT_KEY = 'accept'
      DEFAULT_REJECT_PATTERNS = [/^[a-z]$/, /[0-9]$/, /[A-Z]/].freeze
      DEFAULT_ACCEPT_PATTERNS = [].freeze

      def self.default_config
        super.merge(
          REJECT_KEY => DEFAULT_REJECT_PATTERNS,
          ACCEPT_KEY => DEFAULT_ACCEPT_PATTERNS)
      end

      #
      # Checks the given +context+ for uncommunicative names.
      #
      # @return [Array<SmellWarning>]
      #
      def sniff
        name = context.name.to_s
        return [] if acceptable_name?(name)

        [smell_warning(
          lines: [source_line],
          message: "has the name '#{name}'",
          parameters: { name: name })]
      end

      private

      def acceptable_name?(name)
        accept_patterns.any? { |accept_pattern| name.match accept_pattern } ||
          reject_patterns.none? { |reject_pattern| name.match reject_pattern }
      end

      def reject_patterns
        Array value(REJECT_KEY, context)
      end

      def accept_patterns
        Array value(ACCEPT_KEY, context)
      end
    end
  end
end
