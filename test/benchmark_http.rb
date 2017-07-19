#!/usr/bin/env ruby

require "net/http"
require "json"
require "concurrent"

@execution_times, @threads, *rest = ARGV
@execution_times = @execution_times.to_i
@threads = @threads.to_i

@http = Net::HTTP.new("localhost", "3001")

@logger = Logger.new(STDOUT)

def time_diff_milli(start, finish)
    (finish - start) * 1000.0
end

def rootRequest
	response = @http.request(Net::HTTP::Get.new("/"))

	@logger.info "Root request - Response Code: #{response.code}"
end

def loginRequest

	postHeaders = {'Content-Type': 'application/json', 'Accept': 'application/json'}
	loginRequest = Net::HTTP::Post.new("/sessions",postHeaders)
	loginRequest.body = '{ "user": "00000001-3100-4444-9999-000000000001" }'

	loginResponse = @http.request(loginRequest)
	json = JSON.parse(loginResponse.body)
	sessionId = json["id"]

	@logger.info "Login Request - Response Code: #{loginResponse.code}"
	@logger.info "Session ID is: #{sessionId}"

	sessionId
end

def sessionRequest(sessionId)
	t1 = Time.now
	sessionResponse = @http.request(Net::HTTP::Get.new("/sessions/#{sessionId}?embed=user,permissions,features",{'Accept':'application/json'}))
	t2 = Time.now
	msecs = time_diff_milli t1,t2
	@logger.info "Session Request - Response Code: #{sessionResponse.code} (#{msecs}ms)"
	msecs
rescue StandardError => e
  	@logger.error e
        false
end

def concurrentRequests(requestArray, threads = 5)

	puts "\n\n"
	@logger.info "-------------------------------------------------"
	@logger.info "\e[32mStarting #{requestArray.size} concurrent HTTP requests on #{threads} threads\e[0m"
	@logger.info "-------------------------------------------------"
	successful = 0
	failed = 0     
	totalTime = 0
	pool = Concurrent::ThreadPoolExecutor.new(
		min_threads: threads,
		max_threads: threads,
		max_queue: 100000,
		fallback_policy: :abort
	)

    @logger.info "Thread pool opened"
    t1 = Time.now
	requestArray.each { |sId|
		pool.post do
			msecs = sessionRequest sId
	        if msecs
		        successful += 1
            	totalTime += msecs
	        else
		        failed += 1
	        end
		end
	}
	pool.shutdown
	pool.wait_for_termination
	t2 = Time.now
	msecs = time_diff_milli t1, t2
	puts "\n\n"
	@logger.info "---------------------------------------------------------"
	@logger.info "\e[32mCompleted requests:                  #{successful}\e[0m"
	@logger.info "\e[31mFailed requests:                     #{failed}\e[0m"
	@logger.info "\e[36mTotal execution time (incl fails):   #{msecs.round(2)}ms\e[0m"
	@logger.info "\e[35mAverage time/request (successful)    #{successful.zero? ? '-' : (totalTime/successful).round(2)}ms\e[0m"
	@logger.info "---------------------------------------------------------"
end

def benchmark sId
    reqArray = Array.new(@execution_times.zero? ? 10 : @execution_times, sId)
    concurrentRequests(reqArray,@threads.zero? ? 5 : @threads)
end

benchmark "4c1fd429-4917-43e2-9248-0fb36ed6928e"
