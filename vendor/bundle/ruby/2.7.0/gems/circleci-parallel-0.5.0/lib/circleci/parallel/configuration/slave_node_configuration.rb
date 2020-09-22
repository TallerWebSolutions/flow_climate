require 'circleci/parallel/hook'

module CircleCI
  module Parallel
    class Configuration
      class SlaveNodeConfiguration
        # @api private
        attr_reader :before_sync_hook, :after_sync_hook

        # @api private
        def initialize
          @before_sync_hook = @after_sync_hook = Hook.new
        end

        # Defines a callback that will be invoked on each slave node before syncing all nodes.
        #
        # @param chdir [Boolean] whether the callback should be invoked while changing the current
        #   working directory to the local data directory.
        #
        # @yieldparam local_data_dir [String] the path to the local data directory
        #
        # @return [void]
        #
        # @example
        #   CircleCI::Parallel.configure do |config|
        #     config.on_each_slave_node.before_sync do
        #       File.write('data.json', JSON.generate(some_data))
        #     end
        #   end
        #
        # @see CircleCI::Parallel.local_data_dir
        def before_sync(chdir: true, &block)
          @before_sync_hook = Hook.new(block, chdir)
        end

        # Defines a callback that will be invoked on each slave node after syncing all nodes.
        #
        # @param chdir [Boolean] whether the callback should be invoked while changing the current
        #   working directory to the local data directory.
        #
        # @yieldparam local_data_dir [String] the path to the local data directory
        #
        # @return [void]
        #
        # @example
        #   CircleCI::Parallel.configure do |config|
        #     config.on_each_slave_node.after_sync do
        #       clean_some_intermediate_data
        #     end
        #   end
        #
        # @see CircleCI::Parallel.local_data_dir
        def after_sync(chdir: true, &block)
          @after_sync_hook = Hook.new(block, chdir)
        end
      end
    end
  end
end
