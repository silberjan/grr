# GRR [![Build Status](https://travis-ci.org/j-slvr/grr.svg?branch=master)](https://travis-ci.org/j-slvr/grr-server) [![GitHub release](https://img.shields.io/github/release/j-slvr/grr.svg)]()

> GRR (Grpc Rest Ruby) is a Rack-compliant gRPC server for REST Requests. It is designed to be used for microservice inter-communication in an environment where REST-compliant APIs are already in place. GRR takes REST syntax, wraps it in a protocol buffer and sends the binary request to the server via HTTP/2. On the server side it passes the REST-like object to a rack-compliant app.

## Get started

### Server

To integrate the grr-server in your app, include grr in your dependencies (as of today only via git)

```
gem 'grr', git: 'https://github.com/j-slvr/grr-server.git'
```

To start the server, add a config.ru ([more info](https://github.com/rack/rack/wiki/(tutorial)-rackup-howto)) and start the server with

```
bundle exec rackup -r grr -s grr config.ru -o 0.0.0.0 -p 6575
```

`-o` sets the host and `-p` the port. You may change that according to your environment.

As soon as the output says `...HTTP/2 server running on <host>:<port>` your grpc server is ready to take REST requests.

### Client

Here is an example of how to use the grr-client

``` ruby
require 'grr-client'

client = Grr::Client.new(Host: "localhost", Port: 6575)

request = Grr::RestRequest.new(
    method:       "GET",
    location:     "/", 
    queryString:  "", 
    headers:      "Accept: text/plain, Content-Type: application/json",
    body:         ""
)

response = client.request request
```
All fields on a `Grr::RestRequest` are mandatory. This is due to the fact, that rack requires no field to be null. If you want to do a GET request (or any other method that does not contain a body) just pass an empty string in the body object.

The response object contains a `headers`, `status` and `body` field, Just like a good old HTTP response.

# Under the Hood

The grr protobuf messages look like this

``` protobuf
message RestRequest {
  string method = 1;
  string location = 2;
  string queryString = 3;
  string headers = 4;
  string body = 5;
}

message RestResponse {
  string headers = 1;
  int32 status = 2;
  string body = 3;
}
```

Currently no streaming requests are supprted, however we plan to integrate this functionality in the future.