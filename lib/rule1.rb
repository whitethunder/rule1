require "active_support/configurable"
require "rule1/version"

module Rule1
  include ActiveSupport::Configurable

  autoload :Model, "rule1/model"

  module Models
    autoload :Option, "rule1/models/option"
    autoload :Put,    "rule1/models/put"
    autoload :Quote,  "rule1/models/quote"
  end
end
