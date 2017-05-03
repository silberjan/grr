#!/usr/bin/env ruby

# Usage: $ path/to/greeter_client.rb

this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, 'lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'grpc'
require 'helloworld_services_pb'

def main

  # create client stub for the specified pb service
  stub = Helloworld::Greeter::Stub.new('localhost:50051', :this_channel_is_insecure)

  #check if CLI args were enterd. If not use 'world' as user name
  user = ARGV.size > 0 ?  ARGV[0] : 'world' 


  begin
    resp = stub.say_hello(Helloworld::HelloRequest.new(name: user))
    p "Message form Server: #{resp.message}"
  end 

  begin
    resp = stub.say_hello_again(Helloworld::HelloRequest.new(name: user))
    p "Message from Server: #{resp.message}"
  rescue GRPC::BadStatus => e
    p "Error from Server. Code: #{e.code} Details: #{e.details}"
  end

  #  # stream
  # begin
  #   p "Starting BiDi request"
  #   resps = stub.hello_stream(['hello','hello 2'])
  #   p "BiDi resp: #{resps}"
  #   resps.each { |r| p r }
  #   rescue GRPC::BadStatus => e
  #     p "Error from Server. Code: #{e.code} Details: #{e.details}"
  # end


end

main
