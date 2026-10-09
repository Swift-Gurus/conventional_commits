# frozen_string_literal: true

require "rspec"
require "tmpdir"
require "yaml"

RSpec.describe ConventionalCommits::NextVersionCalculator do
  # Release rules in the mock: ref/fix → patch, feature → patch, breaking → major.
  let(:config_path) { File.expand_path("../support/mocks/config_mock.yml", __dir__) }
  let(:fake_git_class) do
    Struct.new(:tags, :messages) do
      def commit_messages_since(_ref)
        messages
      end
    end
  end

  def next_version(tags:, messages: [], path: config_path, initial: "0.1.0")
    git = fake_git_class.new(tags, messages)
    described_class.new(git:).next_version(cfg_path: path, initial:)
  end

  def config_with_rules(rules)
    mock = YAML.safe_load(File.read(config_path))
    path = File.join(Dir.mktmpdir, "config.yml")
    File.write(path, YAML.dump(mock.merge("release" => { "rules" => rules })))
    path
  end

  context "when there is no version tag yet" do
    it "returns the initial version" do
      expect(next_version(tags: ["nightly"], messages: ["fix: a"])).to eq "0.1.0"
    end

    it "returns a custom initial version" do
      expect(next_version(tags: [], initial: "1.0.0")).to eq "1.0.0"
    end
  end

  context "when commits since the latest tag call for a bump" do
    it "bumps the patch for a fix" do
      expect(next_version(tags: ["1.2.3"], messages: ["fix: repair"])).to eq "1.2.4"
    end

    it "matches a type written as an alias of the rule's type" do
      expect(next_version(tags: ["1.2.3"], messages: ["refactor(core): tidy"])).to eq "1.2.4"
    end

    it "matches a rule written with an alias of the commit's type" do
      expect(next_version(tags: ["1.2.3"], messages: ["feat: add"])).to eq "1.2.4"
    end

    it "bumps the major for a breaking subject" do
      expect(next_version(tags: ["1.2.3"], messages: ["feat(core)!: replace api"])).to eq "2.0.0"
    end

    it "bumps the major for a breaking change footer" do
      message = "fix: change\n\nbody\n\nBREAKING CHANGE: the api is gone"
      expect(next_version(tags: ["1.2.3"], messages: [message])).to eq "2.0.0"
    end

    it "uses the biggest bump of all the commits" do
      expect(next_version(tags: ["1.2.3"], messages: ["fix: a", "feat!: b", "doc: c"])).to eq "2.0.0"
    end

    it "bumps the minor when a rule asks for it" do
      path = config_with_rules([{ "types" => ["feature"], "version" => "minor" }])
      expect(next_version(tags: ["1.2.3"], messages: ["feat: add"], path:)).to eq "1.3.0"
    end

    it "falls back to the type's rule for a breaking change without a breaking rule" do
      path = config_with_rules([{ "types" => ["fix"], "version" => "patch" }])
      expect(next_version(tags: ["1.2.3"], messages: ["fix!: change"], path:)).to eq "1.2.4"
    end
  end

  context "when no commit calls for a release" do
    it "returns nil for types without a rule" do
      expect(next_version(tags: ["1.2.3"], messages: ["doc: explain", "ci: speed up"])).to be_nil
    end

    it "returns nil for messages that are not conventional commits" do
      expect(next_version(tags: ["1.2.3"], messages: ["Merge branch 'main'"])).to be_nil
    end

    it "returns nil when there are no new commits" do
      expect(next_version(tags: ["1.2.3"])).to be_nil
    end
  end

  context "when choosing the latest tag" do
    it "compares tags as versions and ignores other tags" do
      expect(next_version(tags: ["1.9.0", "1.10.0", "nightly", "release-2"], messages: ["fix: a"])).to eq "1.10.1"
    end

    it "accepts v-prefixed tags" do
      expect(next_version(tags: ["v0.2.8", "v0.3.0"], messages: ["fix: a"])).to eq "0.3.1"
    end
  end

  it "rejects a rule with an unknown version" do
    path = config_with_rules([{ "types" => ["fix"], "version" => "huge" }])
    expect do
      next_version(tags: ["1.2.3"], messages: ["fix: a"], path:)
    end.to raise_error(ConventionalCommits::GenericError, /Unknown release version 'huge'/)
  end
end
