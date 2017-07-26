require "grr-client"
require "json"

module RequestBuilder

    class Grpc

        def initialize(http)
            @http = http
        end
     
        def rootRequest
            @http.request(Net::HTTP::Get.new("/"))
        end

        def loginRequest

            postHeaders = {'Content-Type': 'application/json', 'Accept': 'application/json'}
            loginRequest = Net::HTTP::Post.new("/sessions",postHeaders)
            loginRequest.body = '{ "user": "00000001-3100-4444-9999-000000000001" }'

            loginResponse = @http.request(loginRequest)
            json = JSON.parse(loginResponse.body)
            sessionId = json["id"]

            # @logger.info "Login Request - Response Code: #{loginResponse.code}"
            # @logger.info "Session ID is: #{sessionId}"

            sessionId
        end

        def sessionRequest(sessionId)
            t1 = Time.now
            sessionResponse = @http.request(Net::HTTP::Get.new("/sessions/#{sessionId}?embed=user,permissions,features",{'Accept':'application/json'}))
            t2 = Time.now
            msecs = time_diff_milli t1,t2
            # @logger.info "Session Request - Response Code: #{sessionResponse.code} (#{msecs}ms)"
            msecs
        rescue StandardError => e
            @logger.error e
                false
        end

    end
end
