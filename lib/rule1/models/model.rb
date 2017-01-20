require 'hashie'

class Rule1::Model < Hashie::Trash
  include Hashie::Extensions::Dash::Coercion
  include Hashie::Extensions::IgnoreUndeclared
  include Hashie::Extensions::IndifferentAccess
  include Hashie::Extensions::MethodAccess
end
