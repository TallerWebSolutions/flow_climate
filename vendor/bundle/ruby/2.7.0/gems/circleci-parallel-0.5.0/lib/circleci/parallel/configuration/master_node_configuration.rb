require 'circleci/parallel/hook'

module CircleCI
  module Parallel
    class Configuration
      class MasterNodeConfiguration
        # @api private
        attr_reader :before_sync_hook, :before_download_hook, :after_download_hook, :after_sync_hook

        # @api private
        def initialize
          @before_sync_hook = @before_download_hook = @after_download_hook = @after_sync_hook = Hook.new
        end

        # Defines a callback that will be invoked on the master node before syncing all nodes.
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
        #     config.on_master_node.before_sync do
        #       File.write('data.json', JSON.generate(some_data))
        #     end
        #   end
        #
        # @see CircleCI::Parallel.local_data_dir
        def before_sync(chdir: true, &block)
          @before_sync_hook = Hook.new(block, chdir)
        end

        # Defines a callback that will be invoked on the master node before downloading all data
        # from slave nodes.
        #
        # @param chdir [Boolean] whether the callback should be invoked while changing the current
        #   working directory to the download data directory.
        #
        # @yieldparam download_data_dir [String] the path to the download data directory
        #
        # @return [void]
        #
        # @see CircleCI::Parallel.download_data_dir
        def before_download(chdir: true, &block)
          @before_download_hook = Hook.new(block, chdir)
        end

        # Defines a callback that will be invoked on the master node after downloading all data
        # from slave nodes.
        #
        # @param chdir [Boolean] whether the callback should be invoked while changing the current
        #   working directory to the download data directory.
        #
        # @yieldparam download_data_dir [String] the path to the download data directory
        #
        # @return [void]
        #
        # @example
        #   CircleCI::Parallel.configure do |config|
        #     config.on_master_node.after_download do
        #       merged_data = Dir['*/data.json'].each_with_object({}) do |path, merged_data|
        #         data = JSON.parse(File.read(path))
        #         node_name = File.dirname(path)
        #         merged_data[node_name] = data
        #       end
        #
        #       File.write('merged_data.json', JSON.generate(merged_data))
        #     end
        #   end
        #
        # @see CircleCI::Parallel.download_data_dir
        def after_download(chdir: true, &block)
          @after_download_hook = Hook.new(block, chdir)
        end

        # Defines a callback that will be invoked on the master node after syncing all nodes.
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
        #     config.on_master_node.after_sync do
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
