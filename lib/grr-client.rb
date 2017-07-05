#!/usr/bin/env ruby

this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir)
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'grpc'
require 'service/rest_services_pb'
require 'concurrent'
require 'logger'

module Grr
  class Client

    def initialize(**kwargs)
      @host = kwargs.fetch(:Host, '0.0.0.0')
      @port = kwargs.fetch(:Port, '50051')
    end

    def time_diff_milli(start, finish)
      (finish - start) * 1000.0
    end

    def threadedRequests(requestArray)
        # create client stub for the specified pb service
        url = "#{@host}:#{@port}"
        logger.info(url)
        stub = Grr::RestService::Stub.new(url, :this_channel_is_insecure)

        pool = Concurrent::CachedThreadPool.new

        logger.info('Thread pool opened')
        
        requestArray.each { |req|

            pool.post do
                begin
                t1 = Time.now
                logger.info('Start REST request')
                resp = stub.do_request(req)
                t2 = Time.now
                msecs = time_diff_milli t1, t2
                logger.info("Code: #{resp.status}")
                logger.info("Headers: #{resp.headers}")
                logger.info("Message form Server: #{resp.body} (#{msecs}ms)")
                rescue GRPC::BadStatus => e
                    logger.error("Error from Server. Code: #{e.code} Details: #{e.details}")
                end
            end

        }

      pool.shutdown
      pool.wait_for_termination

      logger.info('Thread pool closed')

    end

    private

    def logger
      @logger ||= Logger.new(STDOUT)
    end

  end
end
