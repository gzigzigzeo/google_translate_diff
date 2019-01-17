require "spec_helper"

RSpec.describe GoogleTranslateDiff::Tokenizer do
  subject do
    described_class.tokenize(source)
  end

  shared_examples "tokenizer" do
    it { expect(subject).to eq(tokens) }
  end

  context "empty" do
    let(:source) { "" }
    let(:tokens) { [] }

    it_behaves_like "tokenizer"
  end

  context "pure crlf" do
    let(:source) { "<div>\n</div>" }
    let(:tokens) { [["<div>", :markup], ["</div>", :markup]] }

    it_behaves_like "tokenizer"
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

  context "notranslate" do
    let(:source) do
      "<span class='notranslate'>test</span><b>
<span class='notranslate'>x</span>y</b>"
    end

    let(:tokens) do
      [
        ["<span class='notranslate'>test</span>", :text],
        ["<b>", :markup],
        ["\n<span class='notranslate'>x</span>y", :text],
        ["</b>", :markup]
      ]
    end

    it_behaves_like "tokenizer"
  end

  context "notranslate inside another span" do
    let(:source) do
      "<span><span class='notranslate'>foo<span>bar<br></span>baz</span></span>"
    end

    let(:tokens) do
      [
        ["<span>", :markup],
        ["<span class='notranslate'>foo<span>bar<br></span>baz</span>", :text],
        ["</span>", :markup]
      ]
    end

    it_behaves_like "tokenizer"
  end

  context "notranslate inside another notranslate" do
    let(:source) do
      "<span class='notranslate'>foo" \
      "<span class='notranslate'>bar</span>baz" \
      "</span>"
    end

    let(:tokens) do
      [
        [source, :text]
      ]
    end

    it_behaves_like "tokenizer"
  end

  context "with <br> tag before closing tag" do
    let(:source) do
      "<font size='3'>Смеркалось.<br></font>"
    end

    let(:tokens) do
      [
        ["<font size='3'>", :markup],
        ["Смеркалось.", :text],
        ["<br></font>", :markup]
      ]
    end

    it_behaves_like "tokenizer"
  end

  context "with <?xml:...> tag" do
    let(:source) do
      "Hey!<br />Look!" \
      "<?xml:namespace ns=\"urn:office\" ?>"
    end

    let(:tokens) do
      [
        ["Hey!", :text],
        ["<br />", :markup],
        ["Look!", :text],
        ["<?xml:namespace ns=\"urn:office\" ?>", :markup]
      ]
    end

    it_behaves_like "tokenizer"
  end

  context "bizarre sentences" do
    let(:source) do
      "Набор «Солнечная механика» от 4М — это 6 экспериментов." \
      "\n\nЮному изобретателю предстоит воочию посмотреть на чудеса."
    end

    let(:tokens) do
      [
        ["Набор «Солнечная механика» от 4М — это 6 экспериментов.\n\n", :text],
        ["Юному изобретателю предстоит воочию посмотреть на чудеса.", :text]
      ]
    end

    it_behaves_like "tokenizer"
  end
end
