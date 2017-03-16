require "active_support/configurable"
require "rule1/version"

module Rule1
  include ActiveSupport::Configurable

  autoload :Client,   "rule1/client"
  autoload :Model,    "rule1/model"
  autoload :Request,  "rule1/request"
  autoload :Resource, "rule1/resource"

  module Models
    autoload :Call,   "rule1/models/call"
    autoload :Option, "rule1/models/option"
    autoload :Put,    "rule1/models/put"
    autoload :Quote,  "rule1/models/quote"
  end

  module Requests
    autoload :Options,     "rule1/requests/options"
    autoload :Quotes,      "rule1/requests/quotes"
  end

  module Resources
    autoload :Options, "rule1/resources/options"
    autoload :Quotes,  "rule1/resources/quotes"
  end

  def self.client
    Client.new
  end
end
