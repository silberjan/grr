#!/usr/bin/env ruby

this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, 'lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'grpc'
require 'grr/rest_services_pb'
require 'concurrent'
require 'logger'

def logger
  @logger ||= Logger.new(STDOUT)
end

def time_diff_milli(start, finish)
   (finish - start) * 1000.0
end

def main

  # create client stub for the specified pb service
  stub = Grr::RestService::Stub.new('localhost:6575', :this_channel_is_insecure)

  # pool = Concurrent::FixedThreadPool.new(3)
  pool = Concurrent::CachedThreadPool.new

  logger.info("Thread pool opened")

  pool.post do

    begin
      t1 = Time.now
      logger.info("Start REST request")

      restRequest = Grr::RestRequest.new(
        method:       'POST',
        location:     '/sessions', 
        queryString:  '', 
        headers:      'Accept: text/plain',
        body:         '{ user: \'00000001-3100-4444-9999-000000000001\' }' #Userid of Kevin Cool Jr
      )
      
      resp = stub.do_request(restRequest)
      t2 = Time.now
      msecs = time_diff_milli t1, t2
      logger.info("Code: #{resp.status}")
      logger.info("Headers: #{resp.headers}")
      logger.info("Message form Server: #{resp.body} (#{msecs}ms)")
    rescue GRPC::BadStatus => e
      logger.error("Error from Server. Code: #{e.code} Details: #{e.details}")
    end
      
  end

  pool.shutdown
  pool.wait_for_termination

  logger.info("Thread pool closed")

  exit 0

end

main
