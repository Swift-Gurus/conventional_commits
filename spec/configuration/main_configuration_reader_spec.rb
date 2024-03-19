# frozen_string_literal: true

require "rspec"

RSpec.describe ConventionalCommits::Configuration do
  include Support::Mocks
  let(:file_operations) { Support::Mocks::FileMockOperations.new }
  let(:mocks) { file_operations.mocks }
  let(:reader) { described_class::MainConfigurationReader.new }
  before do
    file_operations.clean_up_mocks
    file_operations.write_mock_data_to_file
  end
  after do
    file_operations.clean_up_mocks
  end

  context "Yaml exists" do
    it "Parses configuration" do
      config = reader.get_configuration
      expect(config.branch.ticket_prefix).to eq "JIRA"
      expect(config.branch.pattern).to eq "<type>/<ticket>/<description>"
      expect(config.branch.lowercase).to eq true
      expect(config.type.options["feat"]).to eq %w[feature feat]
      expect(config.type.options["fix"]).to eq %w[bug bugfix fix]
      expect(config.type.options["ci"]).to eq ["ci"]
      expect(config.type.options["refactor"]).to eq %w[ref refactor refactoring]
    end
  end
end
