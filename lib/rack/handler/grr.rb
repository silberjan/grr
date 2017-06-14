# Rack needs to know how to start the server

require 'grr'

module Rack
  module Handler
    class Grr
      def self.run(app, **kwargs)
        server = ::Grr::RackServer.new(app, **kwargs)
        server.start
      end
    end
  end
end

Rack::Handler.register('grr', 'Rack::Handler::Grr')
