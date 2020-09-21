require_relative '../../spec_helper'
require_lib 'reek/smell_detectors/too_many_constants'

RSpec.describe Reek::SmellDetectors::TooManyConstants do
  let(:config) do
    { Reek::SmellDetectors::TooManyConstants::MAX_ALLOWED_CONSTANTS_KEY => 2 }
  end

  it 'reports the right values' do
    src = <<-RUBY
      class Alfa
        Bravo = Charlie = Delta = 1
      end
    RUBY

    expect(src).to reek_of(:TooManyConstants,
                           lines:   [1],
                           context: 'Alfa',
                           message: 'has 3 constants',
                           source:  'string',
                           count:   3).with_config(config)
  end

  it 'does not report for non-excessive constants' do
    src = <<-RUBY
      class Alfa
        Bravo = Charlie = 1
      end
    RUBY

    expect(src).not_to reek_of(:TooManyConstants).with_config(config)
  end

  it 'does not report when increasing default' do
    src = <<-RUBY
      # :reek:TooManyConstants { max_constants: 3 }
      class Alfa
        Bravo = Charlie = Delta = 1
      end
    RUBY

    expect(src).not_to reek_of(:TooManyConstants).with_config(config)
  end

  it 'does not report when disabled' do
    src = <<-RUBY
      # :reek:TooManyConstants { enabled: false }
      class Alfa
        Bravo = Charlie = Delta = 1
      end
    RUBY

    expect(src).not_to reek_of(:TooManyConstants).with_config(config)
  end

  it 'does not account class definition' do
    src = <<-RUBY
      class Alfa
        Bravo = Charlie = 1
        Delta = Class.new(StandardError)
      end
    RUBY

    expect(src).not_to reek_of(:TooManyConstants).with_config(config)
  end

  it 'does not account struct definition' do
    src = <<-RUBY
      class Alfa
        Bravo = Charlie = 1
        Delta = Struct.new
      end
    RUBY

    expect(src).not_to reek_of(:TooManyConstants).with_config(config)
  end

  it 'counts each constant only once' do
    src = <<-RUBY
      class Alfa
        Bravo = Charlie = 1
      end

      class Delta
        Echo = Foxtrot = 1
      end

      class Golf
        Hotel = India = 1
      end
    RUBY

    expect(src).not_to reek_of(:TooManyConstants).with_config(config)
  end

  it 'does not report outer module when inner module suppressed' do
    src = <<-RUBY
      module Alfa
        # ignore :reek:TooManyConstants
        module Bravo
          Charlie = Delta = Echo = 1
        end
      end
    RUBY

    expect(src).not_to reek_of(:TooManyConstants).with_config(config)
  end

  it 'counts each constant only once for each namespace' do
    src = <<-RUBY
      module Alfa
        Bravo = Charlie = 1

        class Delta
          Echo = 1
        end
      end
    RUBY

    expect(src).not_to reek_of(:TooManyConstants).with_config(config)
  end

  it 'reports for excessive constants inside a module' do
    src = <<-RUBY
      module Alfa
        Bravo = Charlie = Delta = 1
      end
    RUBY

    expect(src).to reek_of(:TooManyConstants, context: 'Alfa').with_config(config)
  end

  it 'reports the full class name' do
    src = <<-RUBY
      module Alfa
        class Bravo
          Charlie = Delta = Echo = 1
        end
      end
    RUBY

    expect(src).to reek_of(:TooManyConstants, context: 'Alfa::Bravo').with_config(config)
  end
end
