require "spec_helper"

RSpec.describe GoogleTranslateDiff::Linearizer do
  let(:array) { described_class.linearize(value) }
  subject { described_class.restore(value, array) }

  shared_examples "linearizer" do
    it { expect(subject).to eq(value) }
  end

  context "with single value" do
    let(:value) { "Value" }

    it_behaves_like "linearizer"
  end

  context "with array" do
    let(:value) { [1, :two, "Three"] }

    it_behaves_like "linearizer"
  end

  context "with hash" do
    let(:value) { { a: "1", b: 2, c: { d: :three } } }

    it_behaves_like "linearizer"
  end
end
