# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "grr/version"

Gem::Specification.new do |spec|
  spec.name          = "grr"
  spec.version       = Grr::VERSION
  spec.authors       = ["Jan Silbersiepe"]
  spec.email         = ["jan.silbersiepe@motionintelligence.net"]

  spec.summary       = 'Rack compatible gRPC server for existing RESTful infrastructures'
  spec.description   = 'GRR stands for gRPC Rack and REST. It is a Rack-compatible gRPC server, that is designed to be implemented in already existing RESTful environments. GRR uses existing REST semantics and wrappes it in a gRPC request. This way the potential of gRPC can be leveraged in an existing RESTful environment, without having to re-write everything.'
  spec.homepage      = 'https://github.com/j-slvr/grr-server'
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'grpc', '~> 1.0'
  spec.add_runtime_dependency 'rack', '~> 2.0'
  spec.add_runtime_dependency 'concurrent-ruby', '~> 1.0'
  spec.add_runtime_dependency 'json', '~> 2.1'

  spec.add_development_dependency 'sinatra', '~> 2.0'
  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency "rake", "~> 10.0"
end