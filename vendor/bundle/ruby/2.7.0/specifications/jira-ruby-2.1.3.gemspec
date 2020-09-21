# -*- encoding: utf-8 -*-
# stub: jira-ruby 2.1.3 ruby lib

Gem::Specification.new do |s|
  s.name = "jira-ruby".freeze
  s.version = "2.1.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "source_code_uri" => "https://github.com/sumoheavy/jira-ruby" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["SUMO Heavy Industries".freeze, "test IO".freeze]
  s.date = "2020-07-21"
  s.description = "API for JIRA".freeze
  s.homepage = "http://www.sumoheavy.com".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3".freeze)
  s.rubygems_version = "3.1.4".freeze
  s.summary = "Ruby Gem for use with the Atlassian JIRA REST API".freeze

  s.installed_by_version = "3.1.4" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<activesupport>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<atlassian-jwt>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<multipart-post>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<oauth>.freeze, [">= 0.5.0", "~> 0.5"])
    s.add_development_dependency(%q<guard>.freeze, [">= 2.13.0", "~> 2.13"])
    s.add_development_dependency(%q<guard-rspec>.freeze, ["~> 4.6", ">= 4.6.5"])
    s.add_development_dependency(%q<pry>.freeze, ["~> 0.10", ">= 0.10.3"])
    s.add_development_dependency(%q<railties>.freeze, [">= 0"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 10.3", ">= 10.3.2"])
    s.add_development_dependency(%q<rspec>.freeze, [">= 3.0.0", "~> 3.0"])
    s.add_development_dependency(%q<webmock>.freeze, [">= 1.18.0", "~> 1.18"])
  else
    s.add_dependency(%q<activesupport>.freeze, [">= 0"])
    s.add_dependency(%q<atlassian-jwt>.freeze, [">= 0"])
    s.add_dependency(%q<multipart-post>.freeze, [">= 0"])
    s.add_dependency(%q<oauth>.freeze, [">= 0.5.0", "~> 0.5"])
    s.add_dependency(%q<guard>.freeze, [">= 2.13.0", "~> 2.13"])
    s.add_dependency(%q<guard-rspec>.freeze, ["~> 4.6", ">= 4.6.5"])
    s.add_dependency(%q<pry>.freeze, ["~> 0.10", ">= 0.10.3"])
    s.add_dependency(%q<railties>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.3", ">= 10.3.2"])
    s.add_dependency(%q<rspec>.freeze, [">= 3.0.0", "~> 3.0"])
    s.add_dependency(%q<webmock>.freeze, [">= 1.18.0", "~> 1.18"])
  end
end
