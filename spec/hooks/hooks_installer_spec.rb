# frozen_string_literal: true

require "rspec"

RSpec.describe ConventionalCommits::Configuration::HooksInstaller do
  include Support::Mocks
  let(:file_operations) { Support::Mocks::FileMockOperations.new }
  let(:mocks) { file_operations.mocks }
  before do
    allow(FileUtils).to receive(:chmod)
    allow(FileUtils).to receive(:mkdir_p)
    allow(File).to receive(:open)
    allow(Dir).to receive(:exist?).and_return(false)
  end

  after do
  end

  context "Hooks installation" do
    it "writes prepare commit message hook" do
      expected_script = construct_expected_script(cmds: [
                                                    "validate_branch_name",
                                                    "prepare_commit_msg --msg_path $1"
                                                  ])

      set_common_expectations(file_name: "prepare-commit-msg", expected_script:)
      described_class.new.install_prepare_commit_msg
    end

    it "writes pre-commit hook" do
      expected_script = construct_expected_script(cmds: [
                                                    "validate_branch_name"
                                                  ])
      set_common_expectations(file_name: "pre-commit", expected_script:)
      described_class.new.install_pre_commit
    end

    it "appends values to pre-commit_hook" do
      expected_script = construct_expected_script(cmds: [
                                                    "validate_branch_name"
                                                  ])
      existed_data = "bash/bin \n make setup"
      set_common_expectations(file_name: "pre-commit", expected_script: "\n#{expected_script}",
                              existed_hook_data: existed_data)
      described_class.new.install_pre_commit
    end

    it "filters commands if they exist in the script" do
      expected_script = construct_expected_script(cmds: [
                                                    "validate_branch_name"
                                                  ])
      existed_data = expected_script
      set_common_expectations(file_name: "pre-commit", expected_script: "", existed_hook_data: existed_data)
      described_class.new.install_pre_commit
    end
  end

  def set_common_expectations(file_name:, expected_script:, existed_hook_data: nil)
    expect(Dir).to receive(:exist?).with(".git/hooks")
    allow(File).to receive(:exist?).with(".git/hooks/#{file_name}").and_return(!existed_hook_data.nil?)
    allow(File).to receive(:open).with(".git/hooks/#{file_name}", existed_hook_data.nil? ? "w" : "a")
    if existed_hook_data
      allow(File).to receive(:open).with(".git/hooks/#{file_name}", "r").and_return(existed_hook_data)
    end
    expect(FileUtils).to receive(:mkdir_p).with(".git/hooks")

    if existed_hook_data
      expect(File).to receive(:add_to_file_data).with(".git/hooks/#{file_name}", expected_script)

    else
      expect(File).to receive(:create_new_file_with_data).with(".git/hooks/#{file_name}", expected_script)
    end

    expect(FileUtils).to receive(:chmod).with("+x", ".git/hooks/#{file_name}")
  end

  def construct_expected_script(cmds: [])
    start = ["#!/bin/sh", "eval \"$(rbenv init -)\""]
    mapped_cmds = cmds.map { |cmd| "bundle exec conventional_commits #{cmd}" }
    (start + mapped_cmds).join("\n")
  end
end
