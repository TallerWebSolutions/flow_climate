require 'pathname'
require_relative '../../spec_helper'
require_lib 'reek/spec'

RSpec.describe Reek::Spec::ShouldReekOf do
  describe 'smell type selection' do
    let(:ruby) { 'def double_thing() @other.thing.foo + @other.thing.foo end' }

    it 'reports duplicate calls by smell type' do
      expect(ruby).to reek_of(:DuplicateMethodCall)
    end

    it 'does not report any feature envy' do
      expect(ruby).not_to reek_of(:FeatureEnvy)
    end
  end

  describe 'different sources of input' do
    context 'when checking code in a string' do
      let(:clean_code) { 'def good() true; end' }
      let(:matcher) { described_class.new(:UncommunicativeVariableName, name: 'y') }
      let(:smelly_code) { 'def x() y = 4; end' }

      it 'matches a smelly String' do
        expect(matcher).to be_matches(smelly_code)
      end

      it 'doesnt match a fragrant String' do
        expect(matcher).not_to be_matches(clean_code)
      end

      it 're-calculates matches every time' do
        matcher.matches? smelly_code
        expect(matcher).not_to be_matches(clean_code)
      end
    end

    context 'when checking code in a File' do
      let(:matcher) { described_class.new(:UncommunicativeMethodName, name: 'x') }

      it 'matches a smelly file' do
        expect(matcher).to be_matches(SMELLY_FILE)
      end

      it 'doesnt match a fragrant file' do
        expect(matcher).not_to be_matches(CLEAN_FILE)
      end
    end
  end

  describe 'smell types and smell details' do
    context 'when passing in smell_details with unknown parameter name' do
      let(:matcher) { described_class.new(:UncommunicativeVariableName, foo: 'y') }
      let(:smelly_code) { 'def x() y = 4; end' }

      it 'raises ArgumentError' do
        expect { matcher.matches?(smelly_code) }.to raise_error(ArgumentError)
      end
    end

    context 'when both are matching' do
      let(:matcher) { described_class.new(:UncommunicativeVariableName, name: 'y') }
      let(:smelly_code) { 'def x() y = 4; end' }

      it 'is truthy' do
        expect(matcher).to be_matches(smelly_code)
      end
    end

    context 'when no smell_type is matching' do
      let(:smelly_code) { 'def dummy() y = 4; end' }

      let(:falsey_matcher) { described_class.new(:FeatureEnvy, name: 'y') }
      let(:truthy_matcher) { described_class.new(:UncommunicativeVariableName, name: 'y') }

      it 'is falsey' do
        expect(falsey_matcher).not_to be_matches(smelly_code)
      end

      it 'sets the proper error message' do
        falsey_matcher.matches?(smelly_code)

        expect(falsey_matcher.failure_message).to\
          match('Expected string to reek of FeatureEnvy, but it didn\'t')
      end

      it 'sets the proper error message when negated' do
        truthy_matcher.matches?(smelly_code)

        expect(truthy_matcher.failure_message_when_negated).to\
          match('Expected string not to reek of UncommunicativeVariableName, but it did')
      end
    end

    context 'when smell type is matching but smell details are not' do
      let(:smelly_code) { 'def double_thing() @other.thing.foo + @other.thing.foo end' }
      let(:matcher) { described_class.new(:DuplicateMethodCall, name: 'foo', count: 15) }

      it 'is falsey' do
        expect(matcher).not_to be_matches(smelly_code)
      end

      it 'sets the proper error message' do
        matcher.matches?(smelly_code)
        expected = <<~TEXT
          Expected string to reek of DuplicateMethodCall (which it did) with smell details {:name=>"foo", :count=>15}, which it didn't.
          The number of smell details I had to compare with the given one was 2 and here they are:
          1.)
          {"context"=>"double_thing", "lines"=>[1, 1], "message"=>"calls '@other.thing' 2 times", "source"=>"string", "name"=>"@other.thing", "count"=>2}
          2.)
          {"context"=>"double_thing", "lines"=>[1, 1], "message"=>"calls '@other.thing.foo' 2 times", "source"=>"string", "name"=>"@other.thing.foo", "count"=>2}
        TEXT

        expect(matcher.failure_message).to eq(expected)
      end

      it 'sets the proper error message when negated' do
        matcher.matches?(smelly_code)

        expect(matcher.failure_message_when_negated).to\
          match('Expected string not to reek of DuplicateMethodCall with smell '\
                  'details {:name=>"foo", :count=>15}, but it did')
      end
    end
  end

  context 'with a smell that is disabled by default' do
    it 'enables the smell detector to match automatically' do
      default_config = Reek::SmellDetectors::UnusedPrivateMethod.default_config
      src = 'class C; private; def foo; end; end'

      aggregate_failures do
        expect(default_config[Reek::SmellConfiguration::ENABLED_KEY]).to be_falsy
        expect(src).to reek_of(:UnusedPrivateMethod)
      end
    end
  end

  describe '#with_config' do
    let(:matcher) { described_class.new(:UncommunicativeVariableName) }
    let(:configured_matcher) { matcher.with_config('accept' => 'x') }

    it 'uses the passed-in configuration for matching' do
      expect(configured_matcher).to be_matches('def foo; q = 2; end')
      expect(configured_matcher).not_to be_matches('def foo; x = 2; end')
    end

    it 'leaves the original matcher intact' do
      expect(configured_matcher).not_to be_matches('def foo; x = 2; end')
      expect(matcher).to be_matches('def foo; x = 2; end')
    end
  end
end
