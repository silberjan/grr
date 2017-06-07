# -*- ruby -*-
# encoding: utf-8

Gem::Specification.new do |s|
  s.name          = 'grr-server'
  s.version       = '0.0.1'
  s.authors       = ['Pichasso Team']
  s.email         = 'jan.silbersiepe@student.hpi.de'
  s.homepage      = 'https://github.com/j-slvr/grpc-ruby-playground'
  s.summary       = 'Rack compatible gRPC server for existing RESTful infrastructures'
  s.description   = 'GRR stands for gRPC Rack and REST. It is a Rack-compatible gRPC server, that is designed to be implemented in already existing RESTful environments. GRR uses existing REST semantics and wrappes it in a gRPC request. This way the potential of gRPC can be leveraged in an existing RESTful environment, without having to re-write everything.'

  s.files         = 'rack_server.rb'
  s.require_paths = ['lib']
  s.platform      = Gem::Platform::RUBY

  s.add_runtime_dependency 'grpc', '~> 1.0'
  s.add_runtime_dependency 'sinatra', '~> 2.0'
  s.add_runtime_dependency 'rack', '~> 2.0'
  s.add_runtime_dependency 'concurrent-ruby', '~> 1.0'

  s.add_development_dependency 'bundler', '~> 1.15'
end
