# frozen_string_literal: true

require "rspec"

RSpec.describe ConventionalCommits::CommitMessageGenerator do
  include Support::Mocks
  let(:file_operations) { Support::Mocks::FileMockOperations.new }
  let(:mocks) { file_operations.mocks }
  let(:mock_branch_name) { mocks.expected_branch_name }
  let(:expected_message) { mocks.expected_commit_message }
  before do
    file_operations.clean_up_mocks
    file_operations.write_mock_data_to_file
  end
  context "Default config and proper message" do
    it "returns proper message" do
      allow_any_instance_of(ConventionalCommits::Git).to receive(:current_branch_name).and_return(mock_branch_name)
      message = described_class.new.prepare_template_message
      expect(message).to eq expected_message
    end

    it "returns proper message with custom pattern" do
      file_operations.update_pattern_in_config("<scope>/<type>/<ticket>-<description>")
      allow_any_instance_of(ConventionalCommits::Git).to receive(:current_branch_name).and_return("ci/1641-run-unit-tests-on-circle-ci")
      message = described_class.new.prepare_template_message
      expect(message).to eq "ci: run unit tests on circle ci\n\n[Describe your work, and put an empty string after]\n\nRef: #JIRA-1641"
    end

    it "returns proper message when branch name contains underscore" do
      allow_any_instance_of(ConventionalCommits::Git).to receive(:current_branch_name).and_return("myScope/feature/1235/build_a_new_feature")
      message = described_class.new.prepare_template_message
      expect(message).to eq expected_message
    end

    it "corrects to the lowercase" do
      allow_any_instance_of(ConventionalCommits::Git).to receive(:current_branch_name).and_return("myScope/FEAT/1235/build-a-new-feature")
      message = described_class.new.prepare_template_message
      expect(message).to eq expected_message
    end

    it "optional scope is not added" do
      allow_any_instance_of(ConventionalCommits::Git).to receive(:current_branch_name).and_return("FEAT/1235/build-a-new-feature")
      message = described_class.new.prepare_template_message
      expect(message).to eq "feat: build a new feature\n\n[Describe your work, and put an empty string after]\n\nRef: #JIRA-1235"
    end
  end

  context "branch contains type tha is not in the list" do
    it "returns proper message" do
      allow_any_instance_of(ConventionalCommits::Git).to receive(:current_branch_name).and_return("my/1243/branch")
      expect do
        message = described_class.new.prepare_template_message
      end.to raise_error
    end
  end
end
