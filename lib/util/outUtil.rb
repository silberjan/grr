module Grr
    class OutUtil
        
        def initialize protocol,logger 
            @protocol = protocol
            @logger = logger
        end

        def printBenchmarkStart numberOfRequests,threads

            # puts "\n\n"
            @logger.info "-------------------------------------------------"
            @logger.info "\e[32mStarting #{numberOfRequests} concurrent #{@protocol} requests on #{threads} threads\e[0m"
            @logger.info "-------------------------------------------------"

        end

        def printBenchmarkEnd numberOfRequests,threads,successful,failed,totalTime,totalTimeSuccessful

            # puts "\n\n"
            @logger.info "---------------------------------------------------------"
            @logger.info "\e[32mExecudted #{numberOfRequests} concurrent #{@protocol} requests on #{threads} threads\e[0m"
            @logger.info "---------------------------------------------------------"
            @logger.info "\e[32mCompleted requests:                  #{successful}\e[0m"
            @logger.info "\e[31mFailed requests:                     #{failed}\e[0m"
            @logger.info "\e[36mTotal execution time (incl fails):   #{totalTime.round(2)}ms\e[0m"
            @logger.info "\e[35mAverage time/request (successful)    #{successful.zero? ? '-' : (totalTimeSuccessful/successful).round(2)}ms\e[0m"
            @logger.info "---------------------------------------------------------"

        end
    end
end