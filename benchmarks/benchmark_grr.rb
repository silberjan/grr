#!/usr/bin/env ruby

this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, '../lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'grr-client'
require 'json'
require 'dotenv/load'
require_relative '../test/requests/grpc'

def benchmark

    execution_times, threads, *rest = ARGV
    execution_times = execution_times.to_i
    threads = threads.to_i

    logger = Logger.new(STDOUT)

    host = ENV["GRR_HOST"] || "localhost"
    port = ENV["GRR_PORT"] || "6575"
    sessionId = ENV["SESSION_ID"] || "6c0d9ced-13c7-482c-9e33-85ff633d4604"

    client = Grr::Client.new(Host: host,Port: port)
    requestBuilder  = RequestBuilder::Grpc.new client

    requestBuilder.concurrentSessionRequests sessionId,execution_times,threads

end 
 
benchmark
