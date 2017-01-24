module Rule1
  class Resource
    attr_reader :client

    def initialize(client)
      @client = client
    end
  end
end
