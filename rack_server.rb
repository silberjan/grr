#!/usr/bin/env ruby
# encoding: ASCII-8BIT

## start the server: rackup -r ./rack_server.rb -s grpc_server config.ru

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
    Encoding::default_external = 'ASCII-8BIT'
    Logger.log.info(Encoding::default_external())
  end

  def start
    url = '0.0.0.0:50051'
    s = GRPC::RpcServer.new
    s.add_http2_port(url, :this_port_is_insecure)
    Logger.log.info("...HTTP/2 server running on #{url}")
    s.handle(GrpcServer.new(app))
    s.run_till_terminated
  end
  
end

# Grpc service implementation
class GrpcServer < Grr::RestService::Service

  attr_reader :app

  def initialize(app)
    @app = app
  end

  # do_request implements the DoRequest rpc method.
  def do_request(rest_req, _call)

    Logger.log.info("Grpc-Rest requested received. Location: #{rest_req.location}; Body: #{rest_req.body}")

    bodyDup = rest_req['body'].dup
    bodyDup.force_encoding("ASCII-8BIT")
    
    env = new_env(rest_req['method'],rest_req['location'],rest_req['queryString'],bodyDup)

    status, headers, body = app.call(env)

    Logger.log.info("Status is: #{status}");
    Logger.log.info("Headers are: #{headers.to_s}");

    bodyString = ""
    body.each do |s|
      bodyString = s
    end

    Grr::RestResponse.new(headers: headers.to_s, status: status, body: bodyString)
  end

  def new_env(method, location, queryString, body)
    {
      'REQUEST_METHOD'   => method,
      'SCRIPT_NAME'      => '',
      'PATH_INFO'        => location,
      'QUERY_STRING'     => queryString,
      'SERVER_NAME'      => 'localhost',
      'SERVER_PORT'      => '8080',
      'rack.version'     => Rack.version.split('.'),
      'rack.url_scheme'  => 'http',
      'rack.input'       => StringIO.new(body),
      'rack.errors'      => StringIO.new(''),
      'rack.multithread' => false,
      'rack.run_once'    => false,
      'rack.multiprocess'=> false
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
