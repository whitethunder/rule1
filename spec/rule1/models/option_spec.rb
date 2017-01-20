require "spec_helper"

describe Rule1::Models::Option do
  let(:params) { {
    symbol: "XYZ"
  } }

  subject(:option) { described_class.new(params) }

  its(:symbol) { is_expected.to eq params[:symbol]}
end
