require File.join(File.dirname(__FILE__), 'lib/reek/version')

Gem::Specification.new do |s|
  s.name = 'reek'
  s.version = Reek::Version::STRING

  s.authors = ['Kevin Rutherford', 'Timo Roessner', 'Matijs van Zuijlen', 'Piotr Szotkowski']
  s.description =
    'Reek is a tool that examines Ruby classes, modules and methods and reports ' \
    'any code smells it finds.'

  s.license = 'MIT'
  s.email = ['timo.roessner@googlemail.com']
  s.extra_rdoc_files = ['CHANGELOG.md', 'License.txt']
  s.files = `git ls-files -z`.split("\0")
  s.executables = s.files.grep(%r{^bin/}).map { |path| File.basename(path) }
  s.homepage = 'https://github.com/troessner/reek'
  s.rdoc_options = %w(--main README.md -x assets/|bin/|config/|features/|spec/|tasks/)
  s.required_ruby_version = '>= 2.4.0'
  s.summary = 'Code smell detector for Ruby'

  s.add_runtime_dependency 'kwalify', '~> 0.7.0'
  s.add_runtime_dependency 'parser',  '< 2.8', '>= 2.5.0.0', '!= 2.5.1.1'
  s.add_runtime_dependency 'psych',   '~> 3.1.0'
  s.add_runtime_dependency 'rainbow', '>= 2.0', '< 4.0'
end
