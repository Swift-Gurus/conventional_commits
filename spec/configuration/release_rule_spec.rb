# frozen_string_literal: true

require "rspec"

RSpec.describe ConventionalCommits::Configuration::ReleaseRule do
  it "reads a list of types" do
    rule = described_class.new("types" => %w[ref fix], "version" => "patch")
    expect(rule.types).to eq %w[ref fix]
    expect(rule.version).to eq "patch"
  end

  it "reads a single type written as `type`" do
    rule = described_class.new("type" => "breaking", "version" => "major")
    expect(rule.types).to eq ["breaking"]
  end

  it "has no types and no version by default" do
    rule = described_class.new
    expect(rule.types).to eq []
    expect(rule.version).to eq "none"
  end
end
