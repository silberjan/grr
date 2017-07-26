require "grr-client"
require "json"
require "util/outUtil"

module RequestBuilder

    class Http

        def initialize(http)
            @http = http
            @logger = Logger.new(STDOUT)
            @util = Grr::OutUtil.new "HTTP",@logger
        end
     
        def rootRequest
            @http.request(Net::HTTP::Get.new("/"))
        end

        def loginRequest userId = "00000001-3100-4444-9999-000000000001"  #Userid of Kevin Cool Jr

            postHeaders = {'Content-Type': 'application/json', 'Accept': 'application/json'}
            loginRequest = Net::HTTP::Post.new("/sessions",postHeaders)
            loginRequest.body = "{ \"user\": \"#{userId}\" }"

            @http.request(loginRequest)
        end

        def sessionRequest sessionId 
            t1 = Time.now
            sessionResponse = @http.request(Net::HTTP::Get.new("/sessions/#{sessionId}?embed=user,permissions,features",{'Accept':'application/json'}))
            t2 = Time.now
            @logger.info "Received Response #{sessionResponse.code}"
            msecs = time_diff_milli t1,t2
            return sessionResponse, msecs
        rescue StandardError => e
            @logger.error e
            false
        end

        def concurrentSessionRequests sId,execution_times_param,threads_param

            execution_times = execution_times_param.zero? ? 10 : execution_times_param
            threads = threads_param.zero? ? 5 : threads_param

            requestArray = Array.new execution_times, sId

            @util.printBenchmarkStart execution_times,threads

            successful = 0
            failed = 0     
            totalTimeSuccessful = 0

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
                    response, msecs = sessionRequest sId
                    if response && response.code.to_i < 400
                        successful += 1
                        totalTimeSuccessful += msecs
                    else
                        failed += 1
                    end
                end
            }
            pool.shutdown
            pool.wait_for_termination
            t2 = Time.now
            totalTime = time_diff_milli t1, t2
            @util.printBenchmarkEnd execution_times,threads,successful,failed,totalTime,totalTimeSuccessful
        end

        private
        def time_diff_milli(start, finish)
            (finish - start) * 1000.0
        end

    end
end
