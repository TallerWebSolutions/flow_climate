require 'circleci/parallel/node'

module CircleCI
  module Parallel
    # Represents a CircleCI build.
    class Build
      attr_reader :number, :node_count

      # @param number [Integer] the build number (`CIRCLE_BUILD_NUM`)
      # @param node_count [Integer] node count of the build (`CIRCLE_NODE_TOTAL`)
      def initialize(number, node_count)
        @number = number
        @node_count = node_count
      end

      def ==(other)
        number == other.number
      end

      alias eql? ==

      def hash
        number.hash ^ node_count.hash
      end

      # @return [Array<Node>] nodes of the build
      def nodes
        @nodes ||= Array.new(node_count) { |index| Node.new(self, index) }.freeze
      end
    end
  end
end
