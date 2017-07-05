require "grr/version"

module Grr
  require 'service/rest_pb'
  require 'service/rest_services_pb'

  require 'grr-server/grpc_server'
  require 'grr-server/rack_server'
end
