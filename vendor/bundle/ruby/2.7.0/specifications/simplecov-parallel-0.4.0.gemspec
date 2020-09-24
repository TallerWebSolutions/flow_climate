# -*- encoding: utf-8 -*-
# stub: simplecov-parallel 0.4.0 ruby lib

Gem::Specification.new do |s|
  s.name = "simplecov-parallel".freeze
  s.version = "0.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Yuji Nakayama".freeze]
  s.bindir = "exe".freeze
  s.date = "2017-12-11"
  s.description = "SimpleCov extension for parallelism support".freeze
  s.email = ["nkymyj@gmail.com".freeze]
  s.homepage = "https://github.com/increments/simplecov-parallel".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.1.2".freeze
  s.summary = "SimpleCov extension for parallelism support".freeze

  s.installed_by_version = "3.1.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<circleci-parallel>.freeze, ["~> 0.5"])
    s.add_runtime_dependency(%q<simplecov>.freeze, ["~> 0.15"])
    s.add_development_dependency(%q<bundler>.freeze, ["~> 1.12"])
  else
    s.add_dependency(%q<circleci-parallel>.freeze, ["~> 0.5"])
    s.add_dependency(%q<simplecov>.freeze, ["~> 0.15"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.12"])
  end
end
