#!/usr/bin/env ruby

# Usage: $ path/to/greeter_server.rb

this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, 'lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'grpc'
require 'helloworld_services_pb'
require 'timeout'
require 'logger'

class Log
  def self.log
    if @logger.nil?
      @logger = Logger.new STDOUT
      @logger.level = Logger::DEBUG
      @logger.datetime_format = '%Y-%m-%d %H:%M:%S '
    end
    @logger
  end
end

# GreeterServer is simple server that implements the Helloworld Greeter service.
class GreeterServer < Helloworld::Greeter::Service

  # say_hello implements the SayHello rpc method.
  def say_hello(hello_req, _call)
    Log.log.info("hello requested for #{hello_req.name}")
    # Log.log.info("Metadata user is #{_call.metadata.user}")
    # sleep(3)
    Log.log.info("#{hello_req.name} was greeted 😁")
    Helloworld::HelloReply.new(message: "Hello #{hello_req.name}")
  end

  # say_hello_again implements the SayHelloAgain rpc method.
  def say_hello_again(hello_req, _unused_call)
    raise GRPC::BadStatus.new(GRPC::Core::StatusCodes::UNIMPLEMENTED, "Hello Again is not yet implemented")
    # Helloworld::HelloReply.new(message: "Hello again #{hello_req.name}")
  end

  # hello_stream implements the HelloStream rpc method.
  def hello_stream(requestStream, _call)
    Log.log.info("Stream. params: #{requestStream}")
    q = EnumeratorQueue.new(self)
    return q.each_item
    # requestStream.each { |r| Log.log.info("#{r}") }
  end

end

# main starts an RpcServer that receives requests to GreeterServer at the sample
# server port.
def main


  url = '0.0.0.0:50051'
  s = GRPC::RpcServer.new
  s.add_http2_port(url, :this_port_is_insecure)
  Log.log.info("...HTTP/2 server running on #{url}")
  s.handle(GreeterServer)
  s.run_till_terminated
end

main
