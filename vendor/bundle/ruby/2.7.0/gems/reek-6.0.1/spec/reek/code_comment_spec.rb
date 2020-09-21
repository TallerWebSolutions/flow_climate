require_relative '../spec_helper'
require_lib 'reek/code_comment'

RSpec.describe Reek::CodeComment do
  context 'with an empty comment' do
    let(:comment) { build_code_comment(comment: '') }

    it 'is not descriptive' do
      expect(comment).not_to be_descriptive
    end

    it 'has an empty config' do
      expect(comment.config).to be_empty
    end
  end

  describe '#descriptive' do
    it 'rejects an empty comment' do
      comment = build_code_comment(comment: '#')
      expect(comment).not_to be_descriptive
    end

    it 'rejects a 1-word comment' do
      comment = build_code_comment(comment: "# alpha\n#  ")
      expect(comment).not_to be_descriptive
    end

    it 'accepts a 2-word comment' do
      comment = build_code_comment(comment: '# alpha bravo  ')
      expect(comment).to be_descriptive
    end

    it 'accepts a multi-word comment' do
      comment = build_code_comment(comment: "# alpha bravo \n# charlie \n   # delta ")
      expect(comment).to be_descriptive
    end
  end

  describe 'good comment config' do
    it 'parses hashed options' do
      comment = '# :reek:DuplicateMethodCall { max_calls: 3 }'
      config = build_code_comment(comment: comment).config

      expect(config).to include('DuplicateMethodCall')
      expect(config['DuplicateMethodCall']).to have_key 'max_calls'
      expect(config['DuplicateMethodCall']['max_calls']).to eq 3
    end

    it 'parses multiple hashed options' do
      comment = <<-RUBY
        # :reek:DuplicateMethodCall { max_calls: 3 }
        # :reek:NestedIterators { enabled: true }
      RUBY
      config = build_code_comment(comment: comment).config

      expect(config).to include('DuplicateMethodCall', 'NestedIterators')
      expect(config['DuplicateMethodCall']['max_calls']).to eq 3
      expect(config['NestedIterators']['enabled']).to be_truthy
    end

    it 'parses multiple hashed options on the same line' do
      comment = <<-RUBY
        #:reek:DuplicateMethodCall { max_calls: 3 } and :reek:NestedIterators { enabled: true }
      RUBY
      config = build_code_comment(comment: comment).config

      expect(config).to include('DuplicateMethodCall', 'NestedIterators')
      expect(config['DuplicateMethodCall']['max_calls']).to eq 3
      expect(config['NestedIterators']).to include('enabled')
      expect(config['NestedIterators']['enabled']).to be_truthy
    end

    it 'parses multiple unhashed options on the same line' do
      comment = '# :reek:DuplicateMethodCall and :reek:NestedIterators'
      config = build_code_comment(comment: comment).config

      expect(config).to include('DuplicateMethodCall', 'NestedIterators')
      expect(config['DuplicateMethodCall']).to include('enabled')
      expect(config['DuplicateMethodCall']['enabled']).to be_falsey
      expect(config['NestedIterators']).to include('enabled')
      expect(config['NestedIterators']['enabled']).to be_falsey
    end

    it 'disables the smell if no options are specifed' do
      comment = '# :reek:DuplicateMethodCall'
      config = build_code_comment(comment: comment).config

      expect(config).to include('DuplicateMethodCall')
      expect(config['DuplicateMethodCall']).to include('enabled')
      expect(config['DuplicateMethodCall']['enabled']).to be_falsey
    end

    it 'does not disable the smell if options are specifed' do
      comment = '# :reek:DuplicateMethodCall { max_calls: 3 }'
      config = build_code_comment(comment: comment).config

      expect(config['DuplicateMethodCall']).not_to include('enabled')
    end

    it 'ignores smells after a space' do
      config = build_code_comment(comment: '# :reek: DuplicateMethodCall').config
      expect(config).not_to include('DuplicateMethodCall')
    end

    it 'removes the configuration options from the comment' do
      original_comment = <<-RUBY
        # Actual
        # :reek:DuplicateMethodCall { max_calls: 3 }
        # :reek:NestedIterators { enabled: true }
        # comment
      RUBY
      comment = build_code_comment(comment: original_comment)

      expect(comment.send(:sanitized_comment)).to eq('Actual comment')
    end
  end
end

RSpec.describe Reek::CodeComment::CodeCommentValidator do
  context 'when the comment contains an unknown detector name' do
    it 'raises BadDetectorInCommentError' do
      expect do
        build_code_comment(comment: '# :reek:DoesNotExist')
      end.to raise_error(Reek::Errors::BadDetectorInCommentError)
    end
  end

  context 'when the comment contains an unparsable detector configuration' do
    it 'raises GarbageDetectorConfigurationInCommentError' do
      expect do
        comment = '# :reek:UncommunicativeMethodName { thats: a: bad: config }'
        build_code_comment(comment: comment)
      end.to raise_error(Reek::Errors::GarbageDetectorConfigurationInCommentError)
    end
  end

  context 'when the legacy comment format was used' do
    it 'raises LegacyCommentSeparatorError' do
      comment = '# :reek:DuplicateMethodCall:'
      expect { build_code_comment(comment: comment) }.
        to raise_error Reek::Errors::LegacyCommentSeparatorError
    end
  end

  describe 'validating configuration keys' do
    context 'when basic options are mispelled' do
      it 'raises BadDetectorConfigurationKeyInCommentError' do
        expect do
          # exclude -> exlude and enabled -> nabled
          comment = '# :reek:UncommunicativeMethodName { exlude: alfa, nabled: true }'
          build_code_comment(comment: comment)
        end.to raise_error(Reek::Errors::BadDetectorConfigurationKeyInCommentError)
      end
    end

    context 'when basic options are not mispelled' do
      it 'does not raise' do
        expect do
          comment = '# :reek:UncommunicativeMethodName { exclude: alfa, enabled: true }'
          build_code_comment(comment: comment)
        end.not_to raise_error
      end
    end

    context 'when unknown custom options are specified' do
      it 'raises BadDetectorConfigurationKeyInCommentError' do
        expect do
          # max_copies -> mx_copies and min_clump_size -> mn_clump_size
          comment = '# :reek:DataClump { mx_copies: 4, mn_clump_size: 3 }'
          build_code_comment(comment: comment)
        end.to raise_error(Reek::Errors::BadDetectorConfigurationKeyInCommentError)
      end
    end

    context 'when valid custom options are specified' do
      it 'does not raise' do
        expect do
          comment = '# :reek:DataClump { max_copies: 4, min_clump_size: 3 }'
          build_code_comment(comment: comment)
        end.not_to raise_error
      end
    end
  end
end
