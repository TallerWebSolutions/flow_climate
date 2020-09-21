# -*- encoding: utf-8 -*-
# stub: rspec-collection_matchers 1.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "rspec-collection_matchers".freeze
  s.version = "1.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/rspec/rspec-collection_matchers/issues", "changelog_uri" => "https://github.com/rspec/rspec-collection_matchers/blob/v1.2.0/Changelog.md", "documentation_uri" => "https://rspec.info/documentation/", "mailing_list_uri" => "https://groups.google.com/forum/#!forum/rspec", "source_code_uri" => "https://github.com/rspec/rspec-collection_matchers" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Hugo Bara\u00FAna".freeze]
  s.date = "2019-09-18"
  s.description = "Collection cardinality matchers, extracted from rspec-expectations".freeze
  s.email = ["hugo.barauna@plataformatec.com.br".freeze]
  s.homepage = "https://github.com/rspec/rspec-collection_matchers".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.1.2".freeze
  s.summary = "rspec-collection_matchers-1.2.0".freeze

  s.installed_by_version = "3.1.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<rspec-expectations>.freeze, [">= 2.99.0.beta1"])
    s.add_development_dependency(%q<bundler>.freeze, [">= 1.3"])
    s.add_development_dependency(%q<activemodel>.freeze, [">= 3.0"])
  else
    s.add_dependency(%q<rspec-expectations>.freeze, [">= 2.99.0.beta1"])
    s.add_dependency(%q<bundler>.freeze, [">= 1.3"])
    s.add_dependency(%q<activemodel>.freeze, [">= 3.0"])
  end
end
