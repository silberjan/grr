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
        response = "{\"id\":\"c6719362-3440-4750-81e9-175f272862d6\",\"self_url\":\"http://localhost:3001/sessions/c6719362-3440-4750-81e9-175f272862d6\",\"user_id\":\"00000001-3100-4444-9999-000000000001\",\"user_url\":\"http://localhost:3001/users/00000001-3100-4444-9999-000000000001\",\"user_agent\":null,\"masqueraded\":false,\"tokens_url\":\"http://localhost:3001/tokens?user_id=00000001-3100-4444-9999-000000000001\",\"masquerade_url\":\"http://localhost:3001/sessions/c6719362-3440-4750-81e9-175f272862d6/masquerade\",\"user\":{\"id\":\"00000001-3100-4444-9999-000000000001\",\"legacy_id\":null,\"password_digest\":\"$2a$10$6rWcXk0ydHXGdHbTVQu5S.YNn4ArapkqsWUtvmPdxfAcPe5n1rcNa\",\"name\":\"Kevin Cool\",\"first_name\":\"Kevin\",\"last_name\":\"Cool Jr.\",\"full_name\":\"Kevin Cool Jr.\",\"display_name\":\"Kevin Cool\",\"admin\":false,\"archived\":false,\"affiliated\":false,\"confirmed\":true,\"anonymous\":false,\"email\":\"kevin.cool@example.com\",\"born_at\":\"1985-04-24T00:00:00Z\",\"image_id\":null,\"accepted_policy_version\":0,\"policy_accepted\":true,\"timezone\":null,\"language\":\"en\",\"preferred_language\":null,\"created_at\":\"2017-07-19T09:44:58Z\",\"updated_at\":\"2017-07-19T09:44:58Z\",\"self_url\":\"http://localhost:3001/users/00000001-3100-4444-9999-000000000001\",\"email_url\":\"http://localhost:3001/users/00000001-3100-4444-9999-000000000001/emails/{id}\",\"emails_url\":\"http://localhost:3001/users/00000001-3100-4444-9999-000000000001/emails\",\"features_url\":\"http://localhost:3001/users/00000001-3100-4444-9999-000000000001/features{?context}\",\"flippers_url\":\"http://localhost:3001/users/00000001-3100-4444-9999-000000000001/features{?context}\",\"permissions_url\":\"http://localhost:3001/users/00000001-3100-4444-9999-000000000001/permissions?user_id=00000001-3100-4444-9999-000000000001{\u0026context}\",\"preferences_url\":\"http://localhost:3001/users/00000001-3100-4444-9999-000000000001/preferences\",\"profile_url\":\"http://localhost:3001/users/00000001-3100-4444-9999-000000000001/profile\"},\"features\":{},\"permissions\":[]}"
        status 200
    else
        status 400
    end
    response
end