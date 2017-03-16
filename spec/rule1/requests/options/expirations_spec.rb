require "spec_helper"

describe Rule1::Requests::Options::Expirations do
  let(:params) {{
    symbol: "RUT"
  }}

  subject { described_class.new(params) }

  its(:symbol) { is_expected.to eq params[:symbol] }
end
