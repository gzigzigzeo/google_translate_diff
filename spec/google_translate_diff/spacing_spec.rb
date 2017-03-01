require "spec_helper"

RSpec.describe GoogleTranslateDiff::Spacing do
  subject { described_class.new(left, right).call }

  let(:left)  { ["a", "    b", "   c   "] }
  let(:right) { %w(А Б В) }

  it { is_expected.to eq(["А", "    Б", "   В   "]) }
end
