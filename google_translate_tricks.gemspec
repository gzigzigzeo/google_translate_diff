# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "google_translate_tricks/version"

Gem::Specification.new do |spec|
  spec.name          = "google_translate_tricks"
  spec.version       = GoogleTranslateTricks::VERSION
  spec.authors       = ["Victor Sokolov"]
  spec.email         = ["gzigzigzeo@evilmartians.com"]

  spec.summary       = %(
    Google Translate API with cache, rate limiting and correct HTML handling
  )
  spec.description = %(
    Google Translate API with cache, rate limiting and correct HTML handling
  )
  spec.homepage = "https://github.com/gzigzigzeo"

  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop"

  spec.add_dependency "google-api-client"
  spec.add_dependency "ox"
  spec.add_dependency "dry-initializer"
end
