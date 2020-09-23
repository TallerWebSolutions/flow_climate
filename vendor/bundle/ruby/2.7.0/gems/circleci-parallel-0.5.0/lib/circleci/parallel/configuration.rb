require 'circleci/parallel/configuration/configuration_collection_proxy'
require 'circleci/parallel/configuration/master_node_configuration'
require 'circleci/parallel/configuration/slave_node_configuration'
require 'circleci/parallel/hook'

module CircleCI
  module Parallel
    class Configuration
      # @return [Boolean] whether progress messages should be outputted to STDOUT (default: false)
      attr_accessor :silent

      # @return [Boolean] whether mock mode is enabled (default: false)
      attr_accessor :mock_mode

      def initialize
        @silent = false
        @mock_mode = false
      end

      # @return [ConfigurationCollectionProxy]
      def on_every_node
        @every_node_configuration ||=
          ConfigurationCollectionProxy.new(master_node_configuration, slave_node_configuration)
      end

      # @return [MasterNodeConfiguration]
      def on_master_node
        master_node_configuration
      end

      # @return [SlaveNodeConfiguration]
      def on_each_slave_node
        slave_node_configuration
      end

      # @deprecated Use `on_every_node.before_sync` instead.
      def before_join(chdir: true, &block)
        on_every_node.before_sync(chdir: chdir, &block)
      end

      # @deprecated Use `on_master_node.after_download` instead.
      def after_download(chdir: true, &block)
        on_master_node.after_download(chdir: chdir, &block)
      end

      # @deprecated Use `on_every_node.after_sync` instead.
      def after_join(chdir: true, &block)
        on_every_node.after_sync(chdir: chdir, &block)
      end

      # @api private
      def master_node_configuration
        @master_node_configuration ||= MasterNodeConfiguration.new
      end

      # @api private
      def slave_node_configuration
        @slave_node_configuration ||= SlaveNodeConfiguration.new
      end
    end
  end
end
