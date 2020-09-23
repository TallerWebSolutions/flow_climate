require 'circleci/parallel/task/base'

module CircleCI
  module Parallel
    module Task
      # @api private
      class MockMaster < Master
        private

        def downloaders
          @downloaders ||= node.other_nodes.map { |other_node| MockDownloader.new(other_node) }
        end

        class MockDownloader < Downloader
          def ready_for_download?
            true
          end

          def scp
            true
          end

          def mark_as_downloaded
            File.write(DOWNLOAD_MARKER_FILE, '')
          end
        end
      end
    end
  end
end
