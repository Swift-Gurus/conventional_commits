# frozen_string_literal: true

require "rspec"
require "yaml"
RSpec.describe ConventionalCommits::BranchNameGenerator do
  include Support::Mocks
  let(:file_operations) { Support::Mocks::FileMockOperations.new }
  let(:mocks) { file_operations.mocks }
  before do
    file_operations.clean_up_mocks
    file_operations.write_mock_data_to_file
  end

  after do
    file_operations.clean_up_mocks
  end

  context "Generation of the name" do
    it "adds to the name" do
      generated_name = described_class.new.generate_name_for(mocks.branch_name)
      expect(generated_name).to eq("feature/1235/build-a-new-feature")
    end

    it "throws error if input doesnt match the pattern" do
      expect do
        generated_name = described_class.new.generate_name_for("my branch")
      end.to raise_error(ConventionalCommits::GenericError, "Doesnt match the pattern expect at least 3 words")
    end

    it "fixes the separator misalignment " do
      generated_name = described_class.new.generate_name_for("feature!1456|my=new_branch")
      expect(generated_name).to eq("feature/1456/my-new-branch")
    end

    it "uses pattern with different separators" do
      file_operations.update_pattern_in_config("<type>/<ticket>-<description>")
      generated_name = described_class.new.generate_name_for("feature!1456|my=new_branch")
      expect(generated_name).to eq("feature/1456-my-new-branch")
    end
  end

  context "Branch components" do
    it "returns split components for a given branch name using rules" do
      components = described_class.new.branch_name_components("feature/1234/my-favorite-branch")
      expect(components).to eq(%w[feature 1234 my-favorite-branch])
    end

    it "returns split components with mixed rules" do
      file_operations.update_pattern_in_config("<type>/<ticket>-<description>")
      components = described_class.new.branch_name_components("feature/1234-my-favorite-branch")
      expect(components).to eq(%w[feature 1234 my-favorite-branch])
    end

    it "throws error when branch doest follow the rules" do
      expect do
        components = described_class.new.branch_name_components("main\n")
      end.to raise_error
    end

    it "returns_valid_branch" do
      expect(described_class.new.is_valid_branch("feature/1234/my-favorite-branch")).to be true
    end

    it "validation throws error if branch doesnt match the pattern" do
      expect do
        generated_name = described_class.new.is_valid_branch("my branch")
      end.to raise_error(ConventionalCommits::GenericError,
                         "The branch doesnt respect the template, expect 2 delimiters. Received: my branch")
    end
  end
end
