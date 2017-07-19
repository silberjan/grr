#!/usr/bin/env ruby

require "net/http"
require "json"
require "concurrent"

@http = Net::HTTP.new("localhost", "3001")

def time_diff_milli(start, finish)
      	(finish - start) * 1000.0
end

def rootRequest
	response = @http.request(Net::HTTP::Get.new("/"))

	puts "Root request - Response Code: #{response.code}"
end

def loginRequest

	postHeaders = {'Content-Type': 'application/json', 'Accept': 'application/json'}
	loginRequest = Net::HTTP::Post.new("/sessions",postHeaders)
	loginRequest.body = '{ "user": "00000001-3100-4444-9999-000000000001" }'

	loginResponse = @http.request(loginRequest)
	json = JSON.parse(loginResponse.body)
	sessionId = json["id"]

	puts "Login Request - Response Code: #{loginResponse.code}"
	puts "Session ID is: #{sessionId}"

	sessionId
end

def sessionRequest(sessionId,id)
	puts "Start session request #{id}"

	t1 = Time.now
	headers = {'Accept':'application/json'}
	sessionRequest = Net::HTTP::Get.new("/sessions/#{sessionId}?embed=user,permissions,features",headers)
	sessionResponse = @http.request(sessionRequest)
	puts "Got esponse for #{id}"	
	t2 = Time.now
	msecs = time_diff_milli t1,t2
	puts "Session Request #{id} - Response Code: #{sessionResponse.code} (#{msecs}ms)"
	# puts "Session: #{sessionResponse.body}"
end

def benchmark
	sId = loginRequest

	pool = Concurrent::CachedThreadPool.new
      	puts "Thread pool opened"
      	t1 = Time.now
	reqArray = Array.new(5)
      	reqArray.each_index { |i|
          	pool.post do
			sessionRequest sId,i
         	end
      	}
      	sleep 5
	puts "Shutting down"
	pool.shutdown
      	pool.wait_for_termination
      	t2 = Time.now
      	msecs = time_diff_milli t1, t2
      	puts "Thread pool closed after #{msecs}ms"

end


benchmark
