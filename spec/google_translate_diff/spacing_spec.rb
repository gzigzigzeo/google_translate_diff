require "spec_helper"

RSpec.describe GoogleTranslateDiff::Spacing do
  subject {  }

  [
    ["a   ", "А", "А   "],
    ["  b ", "Б", "  Б "]
  ].each do |(left, right, result)|
    it { expect(described_class.restore(left, right)).to eq(result) }
  end
end
