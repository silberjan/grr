require "grr-client"
require "json"

module RequestBuilder

    class Grpc

        def initialize(client)
            @client = client
        end

        def rootRequest
            
            rootReq = Grr::RestRequest.new(
                method:       "GET",
                location:     "/", 
                queryString:  "", 
                headers:      "Accept: text/plain, Content-Type: application/json",
                body:         ""
            )

            @client.request(rootReq)

        end

        def loginRequest(userId = "00000001-3100-4444-9999-000000000001")  #Userid of Kevin Cool Jr

            loginReq = Grr::RestRequest.new(
                method:       "POST",
                location:     "/sessions", 
                queryString:  "", 
                headers:      "Accept: text/plain, Content-Type: application/json",
                body:         "{ \"user\": \"#{userId}\" }"
            )

            @client.request(loginReq)
            # puts resp["body"]
            # json = JSON.parse(resp.body)
            # json["id"]

        end

        def sessionRequest(sId)

            sessionRequest = Grr::RestRequest.new(
                method:       "GET",
                location:     "/sessions/" + sId, 
                queryString:  "embed=user,permissions,features", 
                headers:      "Accept: text/plain, Content-Type: application/json",
                body:         ""
            )

            @client.request(sessionRequest)

        end

        def concurrentSessionRequests(sId,execution_times,threads)

            sessionRequest = Grr::RestRequest.new(
                method:       "GET",
                location:     "/sessions/" + sId, 
                queryString:  "embed=user,permissions,features", 
                headers:      "Accept: text/plain, Content-Type: application/json",
                body:         ""
            )

            #session = @client.request(sessionRequest)
            reqArray = Array.new(execution_times.zero? ? 100 : execution_times, sessionRequest)
            @client.concurrentRequests(reqArray,threads.zero? ? 10 : threads)

        end

    end

end