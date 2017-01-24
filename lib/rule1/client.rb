require "oauth"
require "uri"

module Rule1
  class Client
    attr_reader :access_token

    def initialize
      ['API_ENDPOINT', 'ACCESS_TOKEN', 'ACCESS_TOKEN_SECRET', 'CONSUMER_KEY', 'CONSUMER_SECRET'].each do |key|
        raise "#{key} environment variable not set" unless ENV[key]
      end
      @access_token = OAuth::AccessToken.new(consumer, ENV['ACCESS_TOKEN'], ENV['ACCESS_TOKEN_SECRET'])
    end

    def get(uri)
      access_token.get(uri, headers)
    end

    private

    def consumer
      @consumer ||= OAuth::Consumer.new(ENV['CONSUMER_KEY'], ENV['CONSUMER_SECRET'], { site: ENV['API_ENDPOINT'] })
    end

    def headers
      { 'Accept' => 'application/json' }
    end
  end
end
