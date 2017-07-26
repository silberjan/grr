this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, '../lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require "minitest/autorun"
require "grr-client"
require_relative "./requests/grpc"

describe Grr::Client do
  before do
    client = Grr::Client.new Host: "localhost", Port: "6575" 
    @RequestBuilder = RequestBuilder::Grpc.new client 
  end

  describe "when requesting root" do
    it "must respond with code 200" do
      response, time = @RequestBuilder.rootRequest
      response.status.must_equal 200
    end
  end

  describe "when requesting login" do
    it "must respond with code 201" do
      resp, time = @RequestBuilder.loginRequest
      resp["body"].must_equal "{ \"id\" : \"6c0d9ced-13c7-482c-9e33-85ff633d4604\" }"
      resp["status"].must_equal 201
    #   puts "Response is #{resp}"
    #   id.must_equal "6c0d9ced-13c7-482c-9e33-85ff633d4604"
    end
  end

  describe "when requesting session" do
    it "must respond with code 201" do
      response, time = @RequestBuilder.sessionRequest("6c0d9ced-13c7-482c-9e33-85ff633d4604")
      response.status.must_equal 200
    end
  end

  describe "when doing concurrent requests" do
    it "must not fail" do
      @RequestBuilder.concurrentSessionRequests("6c0d9ced-13c7-482c-9e33-85ff633d4604",20,5)
    end
  end

end