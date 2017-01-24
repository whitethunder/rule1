RSpec.describe Rule1::Resource do
  let(:client) { double }

  subject(:resource) { described_class.new(client) }

  its(:client) { is_expected.to eq client }
end
