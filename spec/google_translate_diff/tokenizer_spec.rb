require "spec_helper"

RSpec.describe GoogleTranslateDiff::Tokenizer do
  subject do
    described_class.new(source).tap do |h|
      Ox.sax_parse(h, StringIO.new(source))
      h.cut_last_token
    end
  end

  shared_examples "tokenizer" do
    it { expect(subject.tokens).to eq(tokens) }
  end

  context "pure text" do
    let(:source) { "test\nphrase" }
    let(:tokens) { [[source, :text]] }

    it_behaves_like "tokenizer"
  end

  context "with some markup ending with text" do
    let(:source) { "alfa<span>bravo</span>kilo" }
    let(:tokens) do
      [
        ["alfa", :text],
        ["<span>", :markup],
        ["bravo", :text],
        ["</span>", :markup],
        ["kilo", :text]
      ]
    end

    it_behaves_like "tokenizer"
  end

  context "with some markup ending with tag" do
    let(:source) { "alfa<span>bravo</span>" }
    let(:tokens) do
      [
        ["alfa", :text],
        ["<span>", :markup],
        ["bravo", :text],
        ["</span>", :markup]
      ]
    end

    it_behaves_like "tokenizer"
  end

  context "with some markup ending with script and non-ascii" do
    let(:source) { "аль<span>бра</span>кил<script>js</script><style>b</style>" }
    let(:tokens) do
      [
        ["аль", :text],
        ["<span>", :markup],
        ["бра", :text],
        ["</span>", :markup],
        ["кил", :text],
        ["<script>js</script><style>b</style>", :markup]
      ]
    end

    it_behaves_like "tokenizer"
  end

  context "sentences" do
    let(:source) do
      "! Киловольт. <span>Смеркалось.    Ворчало. Кричало.</span>"
    end

    let(:tokens) do
      [
        ["! ", :text],
        ["Киловольт. ", :text],
        ["<span>", :markup],
        ["Смеркалось.    ", :text],
        ["Ворчало. ", :text],
        ["Кричало.", :text],
        ["</span>", :markup]
      ]
    end

    it_behaves_like "tokenizer"
  end
end
