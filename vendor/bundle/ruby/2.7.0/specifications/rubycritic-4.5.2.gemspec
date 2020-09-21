# -*- encoding: utf-8 -*-
# stub: rubycritic 4.5.2 ruby lib

Gem::Specification.new do |s|
  s.name = "rubycritic".freeze
  s.version = "4.5.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Guilherme Simoes".freeze]
  s.date = "2020-09-04"
  s.description = "RubyCritic is a tool that wraps around various static analysis gems to provide a quality report of your Ruby code.".freeze
  s.email = ["guilherme.rdems@gmail.com".freeze]
  s.executables = ["rubycritic".freeze]
  s.files = ["bin/rubycritic".freeze]
  s.homepage = "https://github.com/whitesmith/rubycritic".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.4.0".freeze)
  s.rubygems_version = "3.1.4".freeze
  s.summary = "RubyCritic is a Ruby code quality reporter".freeze

  s.installed_by_version = "3.1.4" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<flay>.freeze, ["~> 2.8"])
    s.add_runtime_dependency(%q<flog>.freeze, ["~> 4.4"])
    s.add_runtime_dependency(%q<launchy>.freeze, [">= 2.0.0"])
    s.add_runtime_dependency(%q<parser>.freeze, [">= 2.6.0"])
    s.add_runtime_dependency(%q<rainbow>.freeze, ["~> 3.0"])
    s.add_runtime_dependency(%q<reek>.freeze, ["~> 6.0", "< 7.0"])
    s.add_runtime_dependency(%q<ruby_parser>.freeze, ["~> 3.8"])
    s.add_runtime_dependency(%q<simplecov>.freeze, [">= 0.17.0"])
    s.add_runtime_dependency(%q<tty-which>.freeze, ["~> 0.4.0"])
    s.add_runtime_dependency(%q<virtus>.freeze, ["~> 1.0"])
    s.add_development_dependency(%q<appraisal>.freeze, [">= 0"])
    s.add_development_dependency(%q<aruba>.freeze, ["~> 0.12", ">= 0.12.0"])
    s.add_development_dependency(%q<bundler>.freeze, ["~> 2.0", ">= 2.0.0"])
    s.add_development_dependency(%q<byebug>.freeze, ["~> 11.0", ">= 10.0"])
    s.add_development_dependency(%q<cucumber>.freeze, ["~> 3.0", ">= 2.2.0"])
    s.add_development_dependency(%q<diff-lcs>.freeze, ["~> 1.3"])
    s.add_development_dependency(%q<fakefs>.freeze, ["~> 0.10", ">= 0.10.0"])
    s.add_development_dependency(%q<mdl>.freeze, ["~> 0.5.0"])
    s.add_development_dependency(%q<minitest>.freeze, ["~> 5.3", ">= 5.3.0"])
    s.add_development_dependency(%q<minitest-around>.freeze, ["~> 0.5.0", ">= 0.4.0"])
    s.add_development_dependency(%q<mocha>.freeze, ["~> 1.1", ">= 1.1.0"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 12.0", ">= 11.0.0"])
    s.add_development_dependency(%q<rubocop>.freeze, ["~> 0.65.0"])
  else
    s.add_dependency(%q<flay>.freeze, ["~> 2.8"])
    s.add_dependency(%q<flog>.freeze, ["~> 4.4"])
    s.add_dependency(%q<launchy>.freeze, [">= 2.0.0"])
    s.add_dependency(%q<parser>.freeze, [">= 2.6.0"])
    s.add_dependency(%q<rainbow>.freeze, ["~> 3.0"])
    s.add_dependency(%q<reek>.freeze, ["~> 6.0", "< 7.0"])
    s.add_dependency(%q<ruby_parser>.freeze, ["~> 3.8"])
    s.add_dependency(%q<simplecov>.freeze, [">= 0.17.0"])
    s.add_dependency(%q<tty-which>.freeze, ["~> 0.4.0"])
    s.add_dependency(%q<virtus>.freeze, ["~> 1.0"])
    s.add_dependency(%q<appraisal>.freeze, [">= 0"])
    s.add_dependency(%q<aruba>.freeze, ["~> 0.12", ">= 0.12.0"])
    s.add_dependency(%q<bundler>.freeze, ["~> 2.0", ">= 2.0.0"])
    s.add_dependency(%q<byebug>.freeze, ["~> 11.0", ">= 10.0"])
    s.add_dependency(%q<cucumber>.freeze, ["~> 3.0", ">= 2.2.0"])
    s.add_dependency(%q<diff-lcs>.freeze, ["~> 1.3"])
    s.add_dependency(%q<fakefs>.freeze, ["~> 0.10", ">= 0.10.0"])
    s.add_dependency(%q<mdl>.freeze, ["~> 0.5.0"])
    s.add_dependency(%q<minitest>.freeze, ["~> 5.3", ">= 5.3.0"])
    s.add_dependency(%q<minitest-around>.freeze, ["~> 0.5.0", ">= 0.4.0"])
    s.add_dependency(%q<mocha>.freeze, ["~> 1.1", ">= 1.1.0"])
    s.add_dependency(%q<rake>.freeze, ["~> 12.0", ">= 11.0.0"])
    s.add_dependency(%q<rubocop>.freeze, ["~> 0.65.0"])
  end
end
