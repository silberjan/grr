#!/usr/bin/env ruby

# Usage: $ path/to/greeter_client.rb

this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, 'lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'grpc'
require 'helloworld_services_pb'
require 'concurrent'
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

def time_diff_milli(start, finish)
   (finish - start) * 1000.0
end

def main

  # create client stub for the specified pb service
  stub = Helloworld::Greeter::Stub.new('localhost:50051', :this_channel_is_insecure)

  #check if CLI args were enterd. If not use 'world' as user name
  user = ARGV.size > 0 ?  ARGV[0] : 'world' 

  # pool = Concurrent::FixedThreadPool.new(3)
  pool = Concurrent::CachedThreadPool.new

  Log.log.info("Thread pool opened")

  pool.post do

    begin
      t1 = Time.now
      Log.log.info("Start hello request")
      resp = stub.say_hello(Helloworld::HelloRequest.new(name: 'Felix'))
      t2 = Time.now
      msecs = time_diff_milli t1, t2
      Log.log.info("Message form Server: #{resp.message} (#{msecs}ms)")
    rescue GRPC::BadStatus => e
      Log.log.error("Error from Server. Code: #{e.code} Details: #{e.details}")
    end
      
  end

   pool.post do

    begin
      t1 = Time.now
      Log.log.info("Start hello request")
      resp = stub.say_hello(Helloworld::HelloRequest.new(name: 'Tobi'))
      t2 = Time.now
      msecs = time_diff_milli t1, t2
      Log.log.info("Message form Server: #{resp.message} (#{msecs}ms)")
    rescue GRPC::BadStatus => e
      Log.log.error("Error from Server. Code: #{e.code} Details: #{e.details}")
    end
      
  end

  pool.post do

    begin
      t1 = Time.now
      Log.log.info("Start hello_again request")
      resp = stub.say_hello_again(Helloworld::HelloRequest.new(name: 'Felix'))
      t2 = Time.now
      msecs = time_diff_milli t1, t2
      Log.log.info("Message form Server: #{resp.message} (#{msecs}ms)")
    rescue GRPC::BadStatus => e
      Log.log.error("Error from Server. Code: #{e.code} Details: #{e.details}")
    end

    begin
      t1 = Time.now
      Log.log.info("Start hello_again request")
      resp = stub.say_hello_again(Helloworld::HelloRequest.new(name: 'Jan'))
      t2 = Time.now
      msecs = time_diff_milli t1, t2
      Log.log.info("Message form Server: #{resp.message} (#{msecs}ms)")
    rescue GRPC::BadStatus => e
      Log.log.error("Error from Server. Code: #{e.code} Details: #{e.details}")
    end
      
  end

  pool.shutdown
  pool.wait_for_termination

  Log.log.info("all parallel requests done")

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
