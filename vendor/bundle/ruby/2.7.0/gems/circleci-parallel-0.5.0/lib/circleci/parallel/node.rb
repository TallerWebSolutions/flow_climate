module CircleCI
  module Parallel
    # Represents a CircleCI node.
    class Node
      attr_reader :build, :index

      # @param build [Build] the build that the node belongs to
      # @param index [Integer] node index (`CIRCLE_NODE_INDEX`)
      def initialize(build, index)
        @build = build
        @index = index
      end

      def ==(other)
        build == other.build && index == other.index
      end

      alias eql? ==

      def hash
        build.hash ^ index.hash
      end

      # @return [Boolean] whether the node is the master node or not
      def master?
        index.zero?
      end

      # @return [String] the hostname that can be used for `ssh` command to connect between nodes
      def ssh_host
        # https://circleci.com/docs/ssh-between-build-containers/
        "node#{index}"
      end

      alias name ssh_host

      # @return [String] the local data directory where node specific data should be saved in
      #
      # @see CircleCI::Parallel.local_data_dir
      def data_dir
        File.join(BASE_DATA_DIR, ssh_host)
      end

      # @return [Array<Node>] other nodes of the same build
      def other_nodes
        @other_nodes ||= (build.nodes - [self]).freeze
      end
    end
  end
end
