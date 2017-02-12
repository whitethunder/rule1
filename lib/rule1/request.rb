require "hashie"

module Rule1
  class Request < Hashie::Trash
    include Hashie::Extensions::Dash::Coercion
    include Hashie::Extensions::IgnoreUndeclared
    include Hashie::Extensions::IndifferentAccess
    include Hashie::Extensions::MethodAccess

    def get(path)
      uri = URI.escape("#{path}.#{format}?#{query_string}")
      response = client.get(uri)
      JSON.parse(response.body)
    end

    def query_string
      raise "Not implemented"
    end

    def format
      "json"
    end

    private

    def client
      Rule1.client
    end
  end
end
