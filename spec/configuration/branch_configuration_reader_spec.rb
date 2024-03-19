# frozen_string_literal: true

require "json"

RSpec.describe ConventionalCommits::Configuration do
  include Support::Mocks
  let(:file_operations) { Support::Mocks::FileMockOperations.new }
  let(:mocks) { file_operations.mocks }
  let(:reader) { described_class::BranchConfigurationReader.new }
  context "path is empty" do
    it "succeeds" do
      expect do
        reader.get_configuration(path: "")
      end.to raise_error(ConventionalCommits::GenericError, "Path is empty")
    end
  end

  context "Config path is not empty" do
    it "returns mapped configuration" do
      mock_file_open_with(expected: "test")
      received = reader.get_configuration(path: "test")

      expect(received.pattern).to eq("<type>/<ticket>/<description>")
      expect(received.lowercase).to eq(true)
      expect(received.ticket_prefix).to eq("JIRA")
    end
  end

  context "Config path is not set" do
    it "returns mapped configuration" do
      mock_file_open_with(expected: ".conventional_commit/config.yaml")
      received = reader.get_configuration

      expect(received.pattern).to eq("<type>/<ticket>/<description>")
      expect(received.lowercase).to eq(true)
      expect(received.ticket_prefix).to eq("JIRA")
    end
  end

  private

  def mock_configuration_data
    mocks.configuration
  end

  def mock_file_open_with(expected: string)
    allow(File).to receive(:open).with(expected).and_return(mock_configuration_data)
    allow(File).to receive(:exist?).with(expected).and_return(true)
  end
end
