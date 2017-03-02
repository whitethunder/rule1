require "spec_helper"

describe Rule1::Models::Quote do
  let(:params) { {
    symbol: "XYZ",
    last: "12.34",
    opn: "12.30",
    hi: "12.40",
    lo: "12.25",
    vl: "123000"
  } }

  subject(:quote) { described_class.new(params) }

  its(:symbol) { is_expected.to eq params[:symbol] }
  its(:last) { is_expected.to eq params[:last].to_f }
  its(:open) { is_expected.to eq params[:opn].to_f }
  its(:high) { is_expected.to eq params[:hi].to_f }
  its(:low) { is_expected.to eq params[:lo].to_f }
  its(:volume) { is_expected.to eq params[:vl].to_f }
end
