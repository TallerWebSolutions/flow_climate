require_relative '../../spec_helper'
require_lib 'reek/smell_detectors/data_clump'

RSpec.describe Reek::SmellDetectors::DataClump do
  it 'reports the right values' do
    src = <<-RUBY
      class Alfa
        def bravo  (echo, foxtrot); end
        def charlie(echo, foxtrot); end
        def delta  (echo, foxtrot); end
      end
    RUBY

    expect(src).to reek_of(:DataClump,
                           lines:      [2, 3, 4],
                           context:    'Alfa',
                           message:    "takes parameters ['echo', 'foxtrot'] to 3 methods",
                           source:     'string',
                           parameters: ['echo', 'foxtrot'],
                           count:      3)
  end

  it 'does count all occurences' do
    src = <<-RUBY
      class Alfa
        def bravo  (echo, foxtrot); end
        def charlie(echo, foxtrot); end
        def delta  (echo, foxtrot); end

        def golf (juliett, kilo); end
        def hotel(juliett, kilo); end
        def india(juliett, kilo); end
      end
    RUBY

    expect(src).
      to reek_of(:DataClump, lines: [2, 3, 4], parameters: ['echo', 'foxtrot']).
      and reek_of(:DataClump, lines: [6, 7, 8], parameters: ['juliett', 'kilo'])
  end

  %w(class module).each do |scope|
    it "does not report parameter sets < 2 for #{scope}" do
      src = <<-RUBY
        #{scope} Alfa
          def bravo  (echo); end
          def charlie(echo); end
          def delta  (echo); end
        end
      RUBY

      expect(src).not_to reek_of(:DataClump)
    end

    it "does not report less than 3 methods for #{scope}" do
      src = <<-RUBY
        #{scope} Alfa
          def bravo  (echo, foxtrot); end
          def charlie(echo, foxtrot); end
        end
      RUBY

      expect(src).not_to reek_of(:DataClump)
    end

    it 'does not care about the order of arguments' do
      src = <<-RUBY
        #{scope} Alfa
          def bravo  (echo, foxtrot); end
          def charlie(foxtrot, echo); end # <- This is the swapped one!
          def delta  (echo, foxtrot); end
        end
      RUBY

      expect(src).to reek_of(:DataClump,
                             count: 3,
                             parameters: ['echo', 'foxtrot'])
    end

    it 'reports arguments in alphabetical order even if they are never used that way' do
      src = <<-RUBY
        #{scope} Alfa
          def bravo  (foxtrot, echo); end
          def charlie(foxtrot, echo); end
          def delta  (foxtrot, echo); end
        end
      RUBY

      expect(src).to reek_of(:DataClump,
                             count: 3,
                             parameters: ['echo', 'foxtrot'])
    end

    it 'reports parameter sets that are > 2' do
      src = <<-RUBY
        #{scope} Alfa
          def bravo  (echo, foxtrot, golf); end
          def charlie(echo, foxtrot, golf); end
          def delta  (echo, foxtrot, golf); end
        end
      RUBY

      expect(src).to reek_of(:DataClump,
                             count: 3,
                             parameters: ['echo', 'foxtrot', 'golf'])
    end

    it 'detects clumps smaller than the total number of parameters' do
      src = <<-RUBY
        # Total number of parameters is 3 but the clump size is 2.
        #{scope} Alfa
          def bravo  (echo,  foxtrot, golf);    end
          def charlie(echo,  golf,    foxtrot); end
          def delta  (hotel, echo,    foxtrot); end
        end
      RUBY

      expect(src).to reek_of(:DataClump,
                             parameters: ['echo', 'foxtrot'])
    end

    it 'ignores anonymous parameters' do
      src = <<-RUBY
        #{scope} Alfa
          def bravo  (echo, foxtrot, *); end
          def charlie(echo, foxtrot, *); end
          def delta  (echo, foxtrot, *); end
        end
      RUBY

      expect(src).to reek_of(:DataClump,
                             parameters: ['echo', 'foxtrot'])
    end
  end
end
