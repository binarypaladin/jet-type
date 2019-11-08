require File.expand_path("lib/jet/type/version", __dir__)

Gem::Specification.new do |s|
  s.required_ruby_version = ">= 2.5.0"

  s.name          = "jet-type"
  s.version       = Jet::Type.version
  s.authors       = %w[Joshua Hansen]
  s.email         = %w[joshua@epicbanality.com]

  s.summary       = "Safe type coercion for the Jet Toolkit."
  s.description   = s.summary
  s.homepage      = "https://github.com/binarypaladin/jet-type"
  s.license       = "MIT"

  s.files         = %w[LICENSE.txt README.md] + Dir["lib/**/*.rb"]
  s.require_paths = %w[lib]

  s.add_dependency "jet-core", "~> 0.1.0"

  s.add_development_dependency "bundler",  "~> 2.0"
  s.add_development_dependency "m",        "~> 1.5"
  s.add_development_dependency "minitest", "~> 5.0"
  s.add_development_dependency "rake",     "~> 10.0"
  s.add_development_dependency "rubocop",  "~> 0.56"
end
