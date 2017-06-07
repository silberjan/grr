#!/usr/bin/env ruby

## start the server: rackup -r rack_server.rb -s grpc_server config.ru

this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, 'lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'rack'
require 'grpc'
require 'rest_services_pb'

require './logger'

# Simple, rack-compliant web server
class GrpcRackServer

  attr_reader :app

  def initialize(app)
    @app = app
  end

  def start
    url = '0.0.0.0:50051'
    s = GRPC::RpcServer.new
    s.add_http2_port(url, :this_port_is_insecure)
    Logger.log.info("...HTTP/2 server running on #{url}")
    s.handle(GrpcServer)
    s.run_till_terminated
  end
  
end

# Grpc service implementation
class GrpcServer < Grr::RestService::Service

  # do_request implements the DoRequest rpc method.
  def do_request(rest_req, _call)

    Logger.log.info("Grpc-Rest requested received. Location: #{rest_req.location}")
    
    env = new_env(rest_req['method'],rest_req.location,rest_req.queryString)

    status, headers, body = GrpcRackServer.app.call(env)

    Grr::RestResponse.new(headers: headers, status: status, body: body)
  end

  def new_env(method, location, queryString)
    {
      'REQUEST_METHOD'   => method,
      'SCRIPT_NAME'      => '',
      'PATH_INFO'        => location,
      'QUERY_STRING'     => queryString,
      'SERVER_NAME'      => 'localhost',
      'SERVER_PORT'      => '8080',
      'rack.version'     => Rack.version.split('.'),
      'rack.url_scheme'  => 'http',
      'rack.input'       => StringIO.new(''),
      'rack.errors'      => StringIO.new(''),
      'rack.multithread' => false,
      'rack.run_once'    => false
    }
  end

end

# Rack needs to know how to start the server
module Rack
  module Handler
    class GrpcRackServer 
      def self.run(app, options = {})
        server = ::GrpcRackServer.new(app)
        server.start
      end
    end
  end
end

Rack::Handler.register('grpc_server', 'Rack::Handler::GrpcRackServer')
