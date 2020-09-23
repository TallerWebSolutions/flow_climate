# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'circleci/parallel/version'

Gem::Specification.new do |spec|
  spec.name          = 'circleci-parallel'
  spec.version       = CircleCI::Parallel::Version.to_s
  spec.authors       = ['Yuji Nakayama']
  spec.email         = ['nkymyj@gmail.com']

  spec.summary       = 'Provides Ruby APIs for syncing CircleCI parallel nodes ' \
                       'and transferring files between the nodes'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/increments/circleci-parallel'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^spec/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.12'
end
