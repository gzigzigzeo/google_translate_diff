require "spec_helper"

RSpec.describe GoogleTranslateDiff::Request do
  subject { described_class.new(values, options).call }

  let(:api) { double("API") }
  let(:cache_store) { double("Cache store") }
  let(:api_response_wrap) { api_response.map { |v| OpenStruct.new(text: v) } }
  let(:cache_response) { nil }

  before do
    GoogleTranslateDiff.api = api
    GoogleTranslateDiff.cache_store = cache_store

    allow(cache_store).to receive(:read_multi) do |keys|
      cache_response || ([nil] * keys.size)
    end

    allow(cache_store).to receive(:write) { |_, value| value }

    allow(api).to receive(:translate).with(*api_request, options).and_return(
      api_response_wrap
    )
  end

  context "simple case" do
    let(:values) { "Some string" }
    let(:options) { { from: :en, to: :ru } }
    let(:api_request) { ["Some string"] }
    let(:api_response) { ["Какая-то строка"] }

    it { is_expected.to eq("Какая-то строка") }
  end

  context "complex structure, simple case" do
    let(:values) { { title: "One", description: "Two" } }
    let(:options) { { from: :en, to: :ru } }
    let(:api_request) { %w[One Two] }
    let(:api_response) { %w[Один Два] }

    it { is_expected.to eq(title: "Один", description: "Два") }
  end

  context "complex structure" do
    let(:values) { { title: "One", more: { description: "Two" }, skip: nil } }
    let(:options) { { from: :en, to: :ru } }
    let(:api_request) { %w[One Two] }
    let(:api_response) { %w[Один Два] }

    it do
      is_expected.to eq(title: "Один", more: { description: "Два" }, skip: "")
    end
  end

  context "HTML" do
    let(:values) do
      {
        title: "One",
        more: {
          description: "<b>Black</b>",
          color: %(So   <font size='35'><script>One</script><!-- Test -->Red
</font> that)
        }
      }
    end
    let(:options) { { from: :en, to: :ru } }
    let(:api_request) { %w[One Black So Red that] }
    let(:api_response) { %w[Один Черный Что Кра что] }

    it do
      is_expected.to eq(
        title: "Один",
        more: {
          description: "<b>Черный</b>",
          color: %(Что   <font size='35'><script>One</script><!-- Test -->Кра
</font> что)
        }
      )
    end
  end
end
