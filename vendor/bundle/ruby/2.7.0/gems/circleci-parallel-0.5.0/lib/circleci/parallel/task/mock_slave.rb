require 'circleci/parallel/task/base'

module CircleCI
  module Parallel
    module Task
      # @api private
      class MockSlave < Slave
        private

        def downloaded?
          true
        end
      end
    end
  end
end
