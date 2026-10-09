# frozen_string_literal: true

require "rspec"

RSpec.describe ConventionalCommits::CommitMessageValidator do
  include Support::Mocks
  let(:file_operations) { Support::Mocks::FileMockOperations.new }
  let(:mocks) { file_operations.mocks }

  before do
    mock_cfg
  end

  context "when the message respects the format " do
    it "Returns true" do
      mock_expected_message("feat: new feature\n\nbody just body\n\nfooter: my footer")
      result = described_class.new.validate_commit_msg_from_file
      expect(result).to eq true
    end
  end

  context "when the message respects the format with scope " do
    it "Returns true" do
      mock_expected_message("feat(scope): new feature\n\nbody just body\n\nfooter: my footer")
      result = described_class.new.validate_commit_msg_from_file
      expect(result).to eq true
    end
  end

  context "when message doesnt respect the format" do
    it "raises error about the type not found" do
      mock_expected_message("feat: new feature\nbody just body\nfooter: my footer")
      expect do
        described_class.new.validate_commit_msg_from_file
      end.to raise_error ConventionalCommits::GenericError,
                         "Commit Message Doesnt respect the spec, expect to have subject, body and footer"
    end
  end

  context "when subject doesnt respect the format" do
    it "raises error about the type not found" do
      mock_expected_message("feat my awesome feature\n\nbody just body\n\nfooter: my footer")
      expect do
        described_class.new.validate_commit_msg_from_file
      end.to raise_error ConventionalCommits::GenericError,
                         "Subject doesnt respect the format"
    end
  end

  context "when subject doesnt respect the format" do
    it "raises error if body contains template" do
      mock_expected_message("feat:my awesome feature\n\n#{ConventionalCommits::Configuration::DEFAULT_COMMIT_BODY_TEMPLATE}\n\nfooter: my footer")
      expect do
        described_class.new.validate_commit_msg_from_file
      end.to raise_error ConventionalCommits::GenericError,
                         "Body contains template"
    end
  end

  context "when the message file is one git writes for a merge" do
    it "leaves it unvalidated" do
      result = described_class.new.validate_commit_msg_from_file(commit_msg_path: ".git/MERGE_MSG")
      expect(result).to be_nil
    end
  end

  context "when the message file is a worktree's commit message" do
    it "validates it" do
      path = ".git/worktrees/feature/COMMIT_EDITMSG"
      allow(File).to receive(:read_file).with(path).and_return("feat: new feature\n\nbody just body\n\nfooter: my footer")
      result = described_class.new.validate_commit_msg_from_file(commit_msg_path: path)
      expect(result).to eq true
    end
  end

  context "when the message is given as text" do
    it "Returns true for a valid message" do
      result = described_class.new.validate_commit_msg(message: "feat(scope): new feature\n\nbody just body\n\nfooter: my footer")
      expect(result).to eq true
    end

    it "raises error if body contains template" do
      expect do
        described_class.new.validate_commit_msg(message: "feat: new feature\n\n#{ConventionalCommits::Configuration::DEFAULT_COMMIT_BODY_TEMPLATE}\n\nfooter: my footer")
      end.to raise_error ConventionalCommits::GenericError, "Body contains template"
    end

    it "raises error if the message has no subject, body and footer" do
      expect do
        described_class.new.validate_commit_msg(message: "just some words")
      end.to raise_error ConventionalCommits::GenericError,
                         "Commit Message Doesnt respect the spec, expect to have subject, body and footer"
    end
  end

  def mock_cfg
    allow(File).to receive(:open).and_return(mocks.configuration)
    allow(File).to receive(:exist?).and_return(true)
  end

  def mock_expected_message(msg)
    allow(File).to receive(:read_file)
      .with(ConventionalCommits::Configuration::DEFAULT_COMMIT_MSG_PATH)
      .and_return(msg)

    allow(File).to receive(:exist?).and_return(true)
  end
end
