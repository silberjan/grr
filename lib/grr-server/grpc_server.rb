
module Grr
  # Grpc service implementation
  class GrpcServer < Grr::RestService::Service

    attr_reader :app, :logger

    def initialize(app, logger)
      @app = app
      @logger = logger
    end

    # do_request implements the DoRequest rpc method.
    def do_request(rest_req, _call)

      logger.info("Grpc-Rest requested received. Location: #{rest_req.location}; Body: #{rest_req.body}")

      bodyDup = rest_req['body'].dup
      bodyDup.force_encoding("ASCII-8BIT")

      env = new_env(rest_req['method'],rest_req['location'],rest_req['queryString'],bodyDup)

      status, headers, body = app.call(env)

      logger.info("Status is: #{status}");
      logger.info("Headers are: #{headers.to_s}");

      bodyString = ""
      body.each do |s|
        logger.info(s);
        File.write('./error.html', s)
        bodyString = s
      end

      Grr::RestResponse.new(headers: headers.to_s, status: status, body: bodyString)
    end

    def new_env(method, location, queryString, body)
      {
        'REQUEST_METHOD'   => method,
        'HTTP_ACCEPT'      => 'application/json',
        'CONTENT_TYPE'     => 'application/json',
        'SCRIPT_NAME'      => '',
        'PATH_INFO'        => location,
        'QUERY_STRING'     => queryString,
        'CONTENT_LENGTH'   => body.bytesize.to_s,
        'SERVER_NAME'      => 'localhost',
        'SERVER_PORT'      => '6575',
        'rack.version'     => Rack.version.split('.'),
        'rack.url_scheme'  => 'http',
        'rack.input'       => StringIO.new(body),
        'rack.errors'      => StringIO.new(''),
        'rack.multithread' => false,
        'rack.run_once'    => false,
        'rack.multiprocess'=> false,
      }
    end
  end
end
