module Grr  

  # Grpc service implementation
  class GrpcServer < Grr::RestService::Service

    attr_reader :app, :logger

    def initialize(app, logger)
      @app = app
      @logger = logger
    end

    def stream_requests(requests)
      requests.each do |request|
        headers,status,bodyString = rack_call(request)
        # Create new Response Object
        Grr::RestResponse.new(headers: headers, status: status, body: bodyString)
      end
    end

    # do_request implements the DoRequest rpc method.
    def do_request(request, _call)
      headers,status,bodyString = rack_call(request)
      # Create new Response Object
      Grr::RestResponse.new(headers: headers, status: status, body: bodyString)
    end

    private 
    def rack_call(request)
      logger.info("Grpc-Rest requested received. Location: #{request.location};")

      # Duplicate is needed, because request['body'] is frozen.
      bodyDup = request['body'].dup
      bodyDup.force_encoding "ASCII-8BIT" # Rack rquires this encoding
      qsDup = request['queryString'].dup
      qsDup.force_encoding "ASCII-8BIT"

      # Create rack env for the request
      env = new_env(request['method'],request['location'],qsDup,bodyDup)

      # Execute the app's .call() method (Rack standard)
      # blocks execution, sync call
      t1 = Time.now
      # binding.pry
      status, headers, body = app.call(env)
      t2 = Time.now
      msecs = time_diff_milli t1, t2
      logger.info "Got code #{status} (#{msecs.round(2)}ms)"

      # Parse the body (may be chunked)
      bodyString = reassemble_chunks(body)
      # File.write('./out.html',bodyString) # For debugging. Errors are returned in html sometimes, hard to read on the command line.
      return headers.to_s, status, bodyString
    end

    # Rack needs ad ENV to process the request
    # see http://www.rubydoc.info/github/rack/rack/file/SPEC
    def new_env(method, location, queryString, body)
      {
        'REMOTE_ADDR'      => '::1',
        'REQUEST_METHOD'   => method,
        'HTTP_ACCEPT'      => 'application/json', # hardcoded TODO use request header
        'CONTENT_TYPE'     => 'application/json', # hardcoded TODO use request header
        'SCRIPT_NAME'      => '',
        'PATH_INFO'        => location,
        'REQUEST_PATH'     => location,
        'REQUEST_URI'      => location,
        'QUERY_STRING'     => queryString,
        'CONTENT_LENGTH'   => body.bytesize.to_s,
        'SERVER_NAME'      => 'localhost',
        'SERVER_PORT'      => '6575',
        'HTTP_HOST'        => 'localhost:6575',
        'HTTP_USER_AGENT'  => 'grr/0.1.0',
        'SERVER_PROTOCOL'  => 'HTTP/1.1',
        'HTTP_VERSION'     => 'HTTP/1.1',
        'rack.version'     => Rack.version.split('.'),
        'rack.url_scheme'  => 'http',
        'rack.input'       => StringIO.new(body),
        'rack.errors'      => StringIO.new(''),
        'rack.multithread' => false,
        'rack.run_once'    => false,
        'rack.multiprocess'=> false,
      }
    end

    private
    def time_diff_milli(start, finish)
      (finish - start) * 1000.0
    end

    private
    def reassemble_chunks raw_data
      reassembled_data = ""
      position = 0
      raw_data.each do |chunk|
        end_of_chunk_size = chunk.index "\r\n"
        if end_of_chunk_size.nil?
          # logger.info("no chunk found")
          reassembled_data = chunk
          break
        end
        chunk_size = chunk[0..(end_of_chunk_size-1)].to_i 16 # chunk size represented in hex
        # TODO ensure next two characters are "\r\n"
        position = end_of_chunk_size + 2
        end_of_content = position + chunk_size
        str = chunk[position..end_of_content-1]
        reassembled_data << str
        # TODO ensure next two characters are "\r\n"
      end
      reassembled_data
    end

  end
end
