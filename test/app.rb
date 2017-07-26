require 'sinatra'
require 'json'

get '/' do
'This is root'
end

post '/sessions' do

    payload = JSON.parse request.body.read 
    response = "No valid user ID"

    if payload["user"] == "00000001-3100-4444-9999-000000000001"
        response = "{ \"id\" : \"6c0d9ced-13c7-482c-9e33-85ff633d4604\" }"
        status 201
    else
        status 400
    end
    response
end

get '/sessions/:id' do
    response = "No valid session ID"
    if params["id"] == "6c0d9ced-13c7-482c-9e33-85ff633d4604" 
        response = "Got session"
        status 200
    else
        status 400
    end
    response
end