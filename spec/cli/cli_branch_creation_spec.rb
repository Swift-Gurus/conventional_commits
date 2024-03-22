# frozen_string_literal: true

require "open3"

RSpec.describe ConventionalCommits::BranchNameCLI, type: :aruba do
  include Support::Mocks
  let(:file_operations) { Support::Mocks::FileMockOperations.new }
  let(:mocks) { file_operations.mocks }
  let(:branch_name) { mocks.branch_name }
  let(:default_expected_branch_name) { mocks.expected_branch_name }
  let(:original_branch) { ConventionalCommits::Git.new.current_branch_name }
  before do
    clean_up
    clean_up(path: Aruba.config.working_directory)
  end

  after do
    clean_up
    clean_up(path: Aruba.config.working_directory)
    file_operations.delete_directory(path: "tmp")
  end

  # Full string

  it "creates a branch with a name using the rules from default path" do
    set_up
    run_cli_command("branch \"#{branch_name}\"")
    switch_to_branch default_expected_branch_name
    expect(current_branch).to eq(default_expected_branch_name)
    switch_to_branch original_branch
    delete_branch(default_expected_branch_name)
  end

  it "creates a branch with a name using the rules from custom path" do
    set_up(path: Aruba.config.working_directory)
    run_cli_command("branch \"#{branch_name}\" --cfg_path #{mocks.full_path}")
    switch_to_branch default_expected_branch_name
    expect(current_branch).to eq(default_expected_branch_name)
    switch_to_branch original_branch
    delete_branch(default_expected_branch_name)
  end

  it "validates branch with a name using the rules from custom path" do
    original_branch = current_branch
    file_operations.mocks.working_directory = Aruba.config.working_directory
    file_operations.write_mock_data_to_file
    file_operations.mocks.working_directory = ""

    random_branch = "random_branch"
    git_branch(random_branch)
    switch_to_branch random_branch
    expect(current_branch).to eq(random_branch)
    run_cli_command("validate_branch --cfg_path #{mocks.full_path}", aruba: true)

    expect(last_command_started).to have_output eq("The branch doesnt respect the template, expect 2 delimiters. Received: random_branch")
    switch_to_branch original_branch
    delete_branch(random_branch)
  end

  it "prepares commit message using custom path" do
    set_up(path: Aruba.config.working_directory)

    relative_path = ".git/COMMIT_EDITMSG"
    msg_file = full_path relative_path
    file_operations.write_mock_data_to_file(path: msg_file, data: "") # create fake COMMIT_EDITMSG

    run_cli_command("branch \"#{default_expected_branch_name}\" --cfg_path #{mocks.full_path}")
    switch_to_branch(default_expected_branch_name)
    run_cli_command "prepare_commit_msg --msg_path #{msg_file} --cfg_path #{mocks.full_path}"

    data = File.read_file(msg_file)

    expect(data).to eq mocks.expected_commit_message
    switch_to_branch original_branch
    delete_branch(default_expected_branch_name)
  end

  it "replaces subject message with custom" do
    set_up(path: Aruba.config.working_directory)

    relative_path = ".git/COMMIT_EDITMSG"
    msg_file = full_path relative_path
    file_operations.write_mock_data_to_file(path: msg_file, data: "") # create fake COMMIT_EDITMSG

    run_cli_command("branch \"#{default_expected_branch_name}\" --cfg_path #{mocks.full_path}")
    switch_to_branch(default_expected_branch_name)
    run_cli_command "prepare_commit_msg --msg_path #{msg_file} --cfg_path #{mocks.full_path}"

    data = File.read_file(msg_file)

    expect(data).to eq mocks.expected_commit_message
    switch_to_branch original_branch
    delete_branch(default_expected_branch_name)
  end

  it "validates message from file using custom rules and fails" do
    file_operations.mocks.working_directory = Aruba.config.working_directory
    file_operations.write_mock_data_to_file
    relative_path = ".git/COMMIT_EDITMSG"
    msg_file = full_path relative_path
    file_operations.write_mock_data_to_file(path: msg_file, data: "")
    file_operations.mocks.working_directory = ""

    # create fake COMMIT_EDITMSG

    run_cli_command("validate_commit_msg --msg_path #{relative_path} --cfg_path #{mocks.full_path}", aruba: true)

    expect(last_command_started).to have_output eq("Commit Message Doesnt respect the spec, expect to have subject, body and footer")
  end

  it "validates message from file using custom rules and succeeds" do
    file_operations.mocks.working_directory = Aruba.config.working_directory
    file_operations.write_mock_data_to_file
    relative_path = ".git/COMMIT_EDITMSG"
    msg_file = full_path relative_path
    file_operations.write_mock_data_to_file(path: msg_file,
                                            data: "feat: new feature\n\nbody just body\n\nfooter: my footer")
    file_operations.mocks.working_directory = ""

    # create fake COMMIT_EDITMSG

    run_cli_command("validate_commit_msg --msg_path #{relative_path} --cfg_path #{mocks.full_path}", aruba: true)

    expect(last_command_started).to have_output eq("Commit message is valid")
  end

  def set_up(path: "")
    original_branch = current_branch
    file_operations.mocks.working_directory = path
    file_operations.write_mock_data_to_file
  end

  def clean_up(path: "")
    switch_to_branch original_branch
    file_operations.mocks.working_directory = path
    file_operations.delete_directory(path: mocks.directory)
    file_operations.delete_directory(path:) unless path.empty?
    delete_branch(default_expected_branch_name)
  end

  def delete_branch(name)
    run_system_command "git branch -d #{name}"
  end

  def run_system_command(_cmd)
    Open3.popen3(_cmd) { |_stdin, stdout, _stderr, _wait_thr| stdout.read }
  end

  def git_branch(name = "")
    run_system_command "git branch #{name}"
  end

  def switch_to_branch(_name)
    run_system_command "git checkout #{_name}"
  end

  def wait
    sleep 0.2 # have to put sleep since run_command runs async
  end

  def full_path(relative)
    "#{file_operations.mocks.working_directory}/#{relative}"
  end

  def run_cli_command(cmd, aruba: false)
    if aruba
      run_command("conventional_commits #{cmd}")
    else
      Open3.popen3("conventional_commits #{cmd}") { |_stdin, stdout, _stderr, _wait_thr| stdout.read }
    end
  end

  def current_branch
    ConventionalCommits::Git.new.current_branch_name.strip
  end
end
