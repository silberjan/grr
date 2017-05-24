#!/usr/bin/env ruby

# Usage: $ path/to/greeter_client.rb

this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, 'lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

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


  # pool = Concurrent::FixedThreadPool.new(3)
  pool = Concurrent::CachedThreadPool.new

  Log.log.info("Thread pool opened")

  t1 = Time.now

  maxThreads = 0;

  30000.times do |x|
    pool.post do
      maxThreads = pool.length if pool.length > maxThreads
      sleep(1)
    end
  end

  Log.log.info("Pool peaked at #{maxThreads} Threads")
  
  pool.shutdown
  pool.wait_for_termination

  t2 = Time.now
  msecs = time_diff_milli t1, t2
  Log.log.info("all parallel requests done (#{msecs}ms)")

end

main