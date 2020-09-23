require 'fileutils'
require 'circleci/parallel/build'
require 'circleci/parallel/configuration'
require 'circleci/parallel/node'
require 'circleci/parallel/task/master'
require 'circleci/parallel/task/slave'
require 'circleci/parallel/task/mock_master'
require 'circleci/parallel/task/mock_slave'

module CircleCI
  module Parallel
    # @api private
    class Environment
      def configuration
        @configuration ||= Configuration.new
      end

      def configure
        yield configuration
      end

      def current_build
        @current_build ||= Build.new(ENV['CIRCLE_BUILD_NUM'].to_i, ENV['CIRCLE_NODE_TOTAL'].to_i)
      end

      def current_node
        @current_node ||= Node.new(current_build, ENV['CIRCLE_NODE_INDEX'].to_i)
      end

      def sync
        validate!
        task.run
      end

      def puts(*args)
        Kernel.puts(*args) unless configuration.silent
      end

      def clean
        FileUtils.rmtree(WORK_DIR) if Dir.exist?(WORK_DIR)
      end

      private

      def validate!
        raise 'The current environment is not on CircleCI.' unless ENV['CIRCLECI']

        unless ENV['CIRCLE_NODE_TOTAL']
          warn 'Environment variable CIRCLE_NODE_TOTAL is not set. ' \
               'Maybe you forgot adding `parallel: true` to your circle.yml? ' \
               'https://circleci.com/docs/parallel-manual-setup/'
        end
      end

      def task
        @task ||= current_node.master? ? master_task : slave_task
      end

      def master_task
        klass = configuration.mock_mode ? Task::MockMaster : Task::Master
        klass.new(current_node, configuration.master_node_configuration)
      end

      def slave_task
        klass = configuration.mock_mode ? Task::MockSlave : Task::Slave
        klass.new(current_node, configuration.slave_node_configuration)
      end
    end
  end
end
