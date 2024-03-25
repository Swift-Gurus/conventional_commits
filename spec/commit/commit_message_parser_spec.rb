# frozen_string_literal: true

require "rspec"

RSpec.describe ConventionalCommits::CommitMessageParser do
  include Support::Mocks
  let(:file_operations) { Support::Mocks::FileMockOperations.new }
  let(:mocks) { file_operations.mocks }

  before do
  end

  after do
    # Do nothing
  end

  context "when the message respects the format " do
    before do
      mock_cfg
      mock_expected_message("feat(scope): new feature\n\nbody just body\n\nfooter: my footer")
    end
    it "Returns Components" do
      components = described_class.new.message_components
      expect(components[:scope]).to eq "scope"
      expect(components[:title]).to eq "new feature"
      expect(components[:type]).to eq "feat"
    end
  end

  context "when message doesnt respect the format" do
    before do
      mock_cfg
      mock_expected_message("feat: new feature\nbody just body\nfooter: my footer
")
    end
    it "raises error about the type not found" do
      expect do
        described_class.new.message_components
      end.to raise_error ConventionalCommits::GenericError,
                         "Commit Message Doesnt respect the spec, expect to have subject, body and footer"
    end
  end

  context "when subject doesnt respect the format" do
    before do
      mock_cfg
      mock_expected_message("feat my awesome feature\n\nbody just body\n\nfooter: my footer")
    end
    it "raises error about the type not found" do
      expect do
        described_class.new.message_components
      end.to raise_error ConventionalCommits::GenericError,
                         "Subject doesnt respect the format"
    end
  end

  def mock_expected_message(msg)
    allow(File).to receive(:read_file)
      .with(ConventionalCommits::Configuration::DEFAULT_COMMIT_MSG_PATH)
      .and_return(msg)

    allow(File).to receive(:exist?).and_return(true)
  end

  def mock_cfg
    allow(File).to receive(:open).and_return(mocks.configuration)
  end
end
