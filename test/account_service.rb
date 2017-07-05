#!/usr/bin/env ruby

this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, '../lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'grr-client'

def main

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
        body:         '{ user: \'00000001-3100-4444-9999-000000000001\' }' #Userid of Kevin Cool Jr
    )

    client.threadedRequests([rootRequest])

end

main
