# frozen_string_literal: true

require "open3"
require "rbconfig"
require "tmpdir"

# Runs the real executable in a throwaway git repository, so the tags and commits are real.
RSpec.describe "conventional_commits next_version" do
  let(:exe) { File.expand_path("../../exe/conventional_commits", __dir__) }
  let(:lib) { File.expand_path("../../lib", __dir__) }
  let(:config_path) { File.expand_path("../support/mocks/config_mock.yml", __dir__) }

  around do |example|
    Dir.mktmpdir do |dir|
      @repo = dir
      git("init", "-q")
      commit("chore: initial")
      example.run
    end
  end

  def git(*args)
    _output, status = Open3.capture2e("git", "-c", "user.name=test", "-c", "user.email=test@example.com",
                                      *args, chdir: @repo)
    raise "git #{args.join(' ')} failed" unless status.success?
  end

  def commit(message)
    git("commit", "-q", "--allow-empty", "--no-verify", "-m", message)
  end

  def next_version
    output, status = Open3.capture2e(RbConfig.ruby, "-I", lib, exe, "next_version", "--cfg_path", config_path,
                                     chdir: @repo)
    [output.strip, status.exitstatus]
  end

  it "prints the initial version when the repository has no version tag" do
    expect(next_version).to eq ["0.1.0", 0]
  end

  it "prints the next patch version after a fix" do
    git("tag", "0.3.0")
    commit("fix(cli): repair")
    expect(next_version).to eq ["0.3.1", 0]
  end

  it "prints the next major version after a breaking change" do
    git("tag", "v0.3.0")
    commit("feat(cli)!: replace options")
    expect(next_version).to eq ["1.0.0", 0]
  end

  it "prints nothing when only documentation changed" do
    git("tag", "0.3.0")
    commit("doc: explain")
    expect(next_version).to eq ["", 0]
  end

  it "only looks at commits after the latest tag" do
    commit("feat!: old breaking change")
    git("tag", "0.3.0")
    commit("fix: small fix")
    expect(next_version).to eq ["0.3.1", 0]
  end
end
