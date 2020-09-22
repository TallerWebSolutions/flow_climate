require 'circleci/parallel/hook'

module CircleCI
  module Parallel
    class Configuration
      # A convenient proxy to modify both master node and slave node configuration at once.
      class ConfigurationCollectionProxy
        # @api private
        attr_reader :configurations

        # @api private
        def initialize(*configurations)
          @configurations = configurations
        end

        # Defines a callback that will be invoked on every node before syncing all nodes.
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
        #     config.on_every_node.before_sync do
        #       File.write('data.json', JSON.generate(some_data))
        #     end
        #   end
        #
        # @see CircleCI::Parallel.local_data_dir
        def before_sync(chdir: true, &block)
          configurations.each do |configuration|
            configuration.before_sync(chdir: chdir, &block)
          end
        end

        # Defines a callback that will be invoked on every node after syncing all nodes.
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
          configurations.each do |configuration|
            configuration.after_sync(chdir: chdir, &block)
          end
        end
      end
    end
  end
end
