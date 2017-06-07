#!/usr/bin/env ruby

this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, 'lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'grpc'
require 'rest_services_pb'
require 'concurrent'
require 'logger'

class Logger
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
  stub = Grr::RestService::Stub.new('localhost:50051', :this_channel_is_insecure)

  # pool = Concurrent::FixedThreadPool.new(3)
  pool = Concurrent::CachedThreadPool.new

  Logger.log.info("Thread pool opened")

  pool.post do

    begin
      t1 = Time.now
      Logger.log.info("Start REST request")
      restRequest = Grr::RestRequest.new(method: 'GET',location: '/test/route', queryString: 'test=2', headers: 'Accept: text/plain', body: '{data:123}')
      resp = stub.do_request(restRequest)
      t2 = Time.now
      msecs = time_diff_milli t1, t2
      Logger.log.info("Message form Server: #{resp.body} (#{msecs}ms)")
    rescue GRPC::BadStatus => e
      Logger.log.error("Error from Server. Code: #{e.code} Details: #{e.details}")
    end
      
  end

  pool.shutdown
  pool.wait_for_termination

  Logger.log.info("all parallel requests done")

end

main
