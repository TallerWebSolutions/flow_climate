# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks if an example group does not include any tests.
      #
      # This cop is configurable using the `CustomIncludeMethods` option
      #
      # @example usage
      #
      #   # bad
      #   describe Bacon do
      #     let(:bacon)      { Bacon.new(chunkiness) }
      #     let(:chunkiness) { false                 }
      #
      #     context 'extra chunky' do   # flagged by rubocop
      #       let(:chunkiness) { true }
      #     end
      #
      #     it 'is chunky' do
      #       expect(bacon.chunky?).to be_truthy
      #     end
      #   end
      #
      #   # good
      #   describe Bacon do
      #     let(:bacon)      { Bacon.new(chunkiness) }
      #     let(:chunkiness) { false                 }
      #
      #     it 'is chunky' do
      #       expect(bacon.chunky?).to be_truthy
      #     end
      #   end
      #
      # @example configuration
      #
      #   # .rubocop.yml
      #   # RSpec/EmptyExampleGroup:
      #   #   CustomIncludeMethods:
      #   #   - include_tests
      #
      #   # spec_helper.rb
      #   RSpec.configure do |config|
      #     config.alias_it_behaves_like_to(:include_tests)
      #   end
      #
      #   # bacon_spec.rb
      #   describe Bacon do
      #     let(:bacon)      { Bacon.new(chunkiness) }
      #     let(:chunkiness) { false                 }
      #
      #     context 'extra chunky' do   # not flagged by rubocop
      #       let(:chunkiness) { true }
      #
      #       include_tests 'shared tests'
      #     end
      #   end
      #
      class EmptyExampleGroup < Base
        MSG = 'Empty example group detected.'

        # @!method example_group_body(node)
        #   Match example group blocks and yield their body
        #
        #   @example source that matches
        #     describe 'example group' do
        #       it { is_expected.to be }
        #     end
        #
        #   @param node [RuboCop::AST::Node]
        #   @yield [RuboCop::AST::Node] example group body
        def_node_matcher :example_group_body, <<~PATTERN
          (block #{ExampleGroups::ALL.send_pattern} args $_)
        PATTERN

        # @!method example_or_group_or_include?(node)
        #   Match examples, example groups and includes
        #
        #   @example source that matches
        #     it { is_expected.to fly }
        #     describe('non-empty example groups too') { }
        #     it_behaves_like 'an animal'
        #     it_behaves_like('a cat') { let(:food) { 'milk' } }
        #     it_has_root_access
        #
        #   @param node [RuboCop::AST::Node]
        #   @return [Array<RuboCop::AST::Node>] matching nodes
        def_node_matcher :example_or_group_or_include?, <<~PATTERN
          {
            #{Examples::ALL.block_pattern}
            #{ExampleGroups::ALL.block_pattern}
            #{Includes::ALL.send_pattern}
            #{Includes::ALL.block_pattern}
            (send nil? #custom_include? ...)
          }
        PATTERN

        # @!method examples_inside_block?(node)
        #   Match examples defined inside a block which is not a hook
        #
        #   @example source that matches
        #     %w(r g b).each do |color|
        #       it { is_expected.to have_color(color) }
        #     end
        #
        #   @example source that does not match
        #     before do
        #       it { is_expected.to fall_into_oblivion }
        #     end
        #
        #   @param node [RuboCop::AST::Node]
        #   @return [Array<RuboCop::AST::Node>] matching nodes
        def_node_matcher :examples_inside_block?, <<~PATTERN
          (block !#{Hooks::ALL.send_pattern} _ #examples?)
        PATTERN

        # @!method examples_directly_or_in_block?(node)
        #   Match examples or examples inside blocks
        #
        #   @example source that matches
        #     it { expect(drink).to be_cold }
        #     context('when winter') { it { expect(drink).to be_hot } }
        #     (1..5).each { |divisor| it { is_expected.to divide_by(divisor) } }
        #
        #   @param node [RuboCop::AST::Node]
        #   @return [Array<RuboCop::AST::Node>] matching nodes
        def_node_matcher :examples_directly_or_in_block?, <<~PATTERN
          {
            #example_or_group_or_include?
            #examples_inside_block?
          }
        PATTERN

        # @!method examples?(node)
        #   Matches examples defined in scopes where they could run
        #
        #   @example source that matches
        #     it { expect(myself).to be_run }
        #     describe { it { i_run_as_well } }
        #
        #   @example source that does not match
        #     before { it { whatever here wont run anyway } }
        #
        #   @param node [RuboCop::AST::Node]
        #   @return [Array<RuboCop::AST::Node>] matching nodes
        def_node_matcher :examples?, <<~PATTERN
          {
            #examples_directly_or_in_block?
            (begin <#examples_directly_or_in_block? ...>)
          }
        PATTERN

        def on_block(node)
          example_group_body(node) do |body|
            add_offense(node.send_node) unless examples?(body)
          end
        end

        private

        def custom_include?(method_name)
          custom_include_methods.include?(method_name)
        end

        def custom_include_methods
          cop_config
            .fetch('CustomIncludeMethods', [])
            .map(&:to_sym)
        end
      end
    end
  end
end
