#!/usr/bin/env ruby

this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, '../lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'concurrent'
require 'grr-client'
require 'dotenv/load'
require 'rest-client'
require_relative '../test/requests/http'

def benchmark
  execution_times, threads, *rest = ARGV
  execution_times = execution_times.to_i
  threads = threads.to_i

  host = ENV['GRR_HOST'] || 'localhost'
  port = ENV['HTTP_PORT'] || '4567'

  logger = Logger.new(STDOUT)

  requestBuilder = RequestBuilder::Http.new "#{host}:#{port}"

  resp, msecs = requestBuilder.loginRequest
  json = JSON.parse(resp.body)
  sessionId = json['id']
  logger.info "Session id is #{sessionId}"

  requestBuilder.concurrentSessionRequests sessionId, execution_times, threads
end

benchmark
