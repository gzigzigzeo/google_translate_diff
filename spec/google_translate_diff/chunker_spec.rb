require "spec_helper"

RSpec.describe GoogleTranslateDiff::Chunker do
  subject { described_class.new(source, limit: 20, count_limit: 5).call }

  let(:a_word) { (["a"] * 10).join }
  let(:b_word) { (["a"] * 7).join }
  let(:z_word) { (["a"] * 30).join }
  let(:x_word) { "x" }

  shared_examples "chunker" do
    it { is_expected.to eq(chunks) }
  end

  context "not splits if fits" do
    let(:source) { %w(a b c) }
    let(:chunks) { [%w(a b c)] }

    it_behaves_like "chunker"
  end

  context "splits by rough borders" do
    let(:source) { [a_word, a_word, a_word] }
    let(:chunks) { [[a_word, a_word], [a_word]] }

    it_behaves_like "chunker"
  end

  context "splits by non-rogugh borders" do
    let(:source) { [b_word, b_word, b_word, a_word] }
    let(:chunks) { [[b_word, b_word], [b_word, a_word]] }

    it_behaves_like "chunker"
  end

  context "splits by count" do
    let(:source) { [x_word] * 10 }
    let(:chunks) { [[x_word] * 6, [x_word] * 4] }

    it_behaves_like "chunker"
  end

  context "raises if part is too long" do
    let(:source) { [z_word] }
    let(:chunks) { [[z_word]] }

    it { expect { subject }.to raise_error(/Too long part/) }
  end
end
