require "spec_helper"

RSpec.describe GoogleTranslateTricks::Tokenizer do
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
    let(:source) { "альфа<span>браво</span>кило<script>js</script>" }

    let(:tokens) do
      [
        ["альфа", :text],
        ["<span>", :markup],
        ["браво", :text],
        ["</span>", :markup],
        ["кило", :text],
        ["<script>js</script>", :markup]
      ]
    end

    it_behaves_like "tokenizer"
  end

  context "sentences" do
    let(:source) { "Киловольт. <span>Смеркалось. Журчало. Ворчало. Кричало.</span>" }

    let(:tokens) do
      [
        ["Киловольт. ", :text],
        ["<span>", :markup],
        ["Смеркалось. ", :text],
        ["Журчало. ", :text],
        ["Ворчало. ", :text],
        ["Кричало.", :text],
        ["</span>", :markup]
      ]
    end

    it_behaves_like "tokenizer"
  end
end
