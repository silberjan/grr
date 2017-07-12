#!/usr/bin/env ruby

this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, '../lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'grr-client'
require 'json'

def main

    logger = Logger.new(STDOUT)

    client = Grr::Client.new(Port: "6575", Host:"localhost" )

    rootRequest = Grr::RestRequest.new(
        method:       'GET',
        location:     '/', 
        queryString:  '', 
        headers:      'Accept: text/plain, Content-Type: application/json',
        body: ''
    )

    loginRequest = Grr::RestRequest.new(
        method:       'POST',
        location:     '/sessions', 
        queryString:  '', 
        headers:      'Accept: text/plain, Content-Type: application/json',
        body:         '{ "user": "00000001-3100-4444-9999-000000000001" }' #Userid of Kevin Cool Jr
    )

    # resp = client.request(loginRequest)
    # json = JSON.parse(resp.body)
    # sessionId = json["id"]
    sessionId = 'b43b98fa-1795-4dd2-8d90-1984d67d9ece'
    logger.info("SessionId is #{sessionId}")

    sessionRequest = Grr::RestRequest.new(
        method:       'GET',
        location:     '/sessions/' + sessionId + '/', 
        queryString:  'embed=user,permissions,features', 
        headers:      'Accept: text/plain, Content-Type: application/json',
        body:         ''
    )

    # session = client.request(sessionRequest)
    client.concurrentRequests([sessionRequest,sessionRequest,sessionRequest,sessionRequest,sessionRequest,sessionRequest,sessionRequest,sessionRequest,sessionRequest,sessionRequest])

end

main
