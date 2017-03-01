# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "google_translate_diff/version"

# rubocop:disable Metrics/BlockLength
Gem::Specification.new do |spec|
  spec.name          = "google_translate_diff"
  spec.version       = GoogleTranslateDiff::VERSION
  spec.authors       = ["Victor Sokolov"]
  spec.email         = ["gzigzigzeo@evilmartians.com"]

  spec.summary       = %(
Google Translate API wrapper helps to translate only changes between revisions
of big texts.
  )
  spec.description = %(
Google Translate API wrapper helps to translate only changes between revisions
of big texts.
  )
  spec.homepage = "https://github.com/gzigzigzeo/google_translate_diff"

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
  spec.add_development_dependency "redis"
  spec.add_development_dependency "connection_pool"
  spec.add_development_dependency "redis-namespace"
  spec.add_development_dependency "ratelimit"

  spec.add_dependency "google-cloud-translate"
  spec.add_dependency "ox"
  spec.add_dependency "dry-initializer"
  spec.add_dependency "punkt-segmenter"
end
# rubocop:enable Metrics/BlockLength
