RSpec.describe Rule1::Request do
  module Rule1
    module Requests
      class Overridden < Request
        def query_string
          "query%20string"
        end
      end
    end
  end

  module Rule1
    module Requests
      class NotOverridden < Request; end
    end
  end

  describe "#query_string" do
    context "when the method is overridden" do
      subject(:request) { Rule1::Requests::Overridden.new }

      its(:query_string) { is_expected.to eq "query%20string" }
    end

    context "when the method is not overridden" do
      subject(:request) { Rule1::Requests::NotOverridden.new }

      it "raises an error" do
        expect {
          request.query_string
        }.to raise_error(RuntimeError, "Not implemented")
      end
    end
  end
end
