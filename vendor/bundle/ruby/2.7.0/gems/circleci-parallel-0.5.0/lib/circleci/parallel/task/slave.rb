require 'circleci/parallel/task/base'

module CircleCI
  module Parallel
    module Task
      # @api private
      class Slave < Base
        def run
          create_node_data_dir
          configuration.before_sync_hook.call(node.data_dir)
          mark_as_syncing
          wait_for_master_node_to_download
          configuration.after_sync_hook.call(node.data_dir)
          done
        end

        private

        def wait_for_master_node_to_download
          # TODO: Consider implementing timeout mechanism
          Parallel.puts('Waiting for master node to download data...')
          Kernel.sleep(1) until downloaded?
        end

        def downloaded?
          File.exist?(DOWNLOAD_MARKER_FILE)
        end
      end
    end
  end
end
