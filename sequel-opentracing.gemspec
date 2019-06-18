
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "sequel/opentracing/version"

Gem::Specification.new do |spec|
  spec.name          = "sequel-opentracing"
  spec.version       = Sequel::Opentracing::VERSION
  spec.authors       = ["larte"]
  spec.email         = ["devops@digitalgoodie.com"]

  spec.summary       = 'Sequel OpenTracing intrumentation'
  spec.description   = ''
  spec.homepage      = 'https://github.com/foodiefm/repo'
  spec.license       = 'BSD-3-Clause'

  spec.files         = %w(README.md Rakefile) + Dir.glob("{doc,lib}/**/*")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'opentracing_test_tracer', '~> 0.1'
  spec.add_development_dependency 'rubocop', '~> 0.71.0'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.33.0'
  spec.add_development_dependency 'sqlite3', '~> 1.4'
  spec.add_development_dependency 'database_cleaner', '~> 1.7'

  spec.add_dependency 'sequel'
  spec.add_dependency 'opentracing', '~> 0.4'
end
