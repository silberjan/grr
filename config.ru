require 'sinatra'
 
get '/' do
'Hello world!'
end

# Run application for rack config.ru
run Sinatra::Application
