require "spec_helper"

describe Rule1::Models::Quote do
  let(:params) { {
    symbol: "XYZ",
    last: "12.34"
  } }

  subject(:option) { described_class.new(params) }

  its(:symbol) { is_expected.to eq params[:symbol] }
  its(:last) { is_expected.to eq params[:last].to_f }
end
