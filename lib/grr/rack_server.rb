require 'grpc'

module Grr
  class RackServer
    attr_reader :app

    def initialize(app, **kwargs)
      @app = app
      @host = kwargs.fetch(:Host, '0.0.0.0')
      @port = kwargs.fetch(:Port, '50051')

      Encoding::default_external = 'ASCII-8BIT'
      logger.info(Encoding::default_external())
    end

    def start
      url = "#{@host}:#{@port}"

      s = GRPC::RpcServer.new
      s.add_http2_port url, :this_port_is_insecure

      logger.info "...HTTP/2 server running on #{url}"

      s.handle Grr::GrpcServer.new(app, logger)

      s.run_till_terminated

      logger.info 'Shutdown...'
    end

    private

    def logger
      @logger ||= Logger.new(STDOUT)
    end
  end
end
