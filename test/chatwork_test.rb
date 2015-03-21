require File.expand_path('../helper', __FILE__)

class ChatWorkTest < Service::TestCase
  def setup
    @stubs  = Faraday::Adapter::Test::Stubs.new
    @token  = 'TOooooooooooooooooooooooooooOKEN'
    @roomid = 'ROOM_ID'
    @config = {
      "token" => @token,
      "rooms" => @roomid
    }
  end

  def test_push
    @stubs.post "/v1/rooms/#{@roomid}/messages" do |env|
      assert_equal 'api.chatwork.com',  env[:url].host
      assert_equal 'https',             env[:url].scheme
      assert_equal 'application/json',  env[:request_headers]['Content-Type']
      assert_equal 'push',              env[:request_headers]['X-GitHub-Event']
      assert_equal :post,               env[:method]
      [200, {}, '']
    end

    service(:push, @config).receive_push
  end

  def test_pull
    @stubs.post "/v1/rooms/#{@roomid}/messages" do |env|
      assert_equal 'api.chatwork.com',  env[:url].host
      assert_equal 'https',             env[:url].scheme
      assert_equal 'application/json',  env[:request_headers]['Content-Type']
      assert_equal 'pull_request',      env[:request_headers]['X-GitHub-Event']
      assert_equal :post,               env[:method]
      [200, {}, '']
    end

    service(:pull_request, @config).receive_pull_request
  end

  def test_issues
    @stubs.post "/v1/rooms/#{@roomid}/messages" do |env|
      assert_equal 'api.chatwork.com',  env[:url].host
      assert_equal 'https',             env[:url].scheme
      assert_equal 'application/json',  env[:request_headers]['Content-Type']
      assert_equal 'issues',            env[:request_headers]['X-GitHub-Event']
      assert_equal :post,               env[:method]
      [200, {}, '']
    end

    service(:issues, @config).receive_issues
  end

  def service(*args)
    super Service::ChatWork, *args
  end
end
