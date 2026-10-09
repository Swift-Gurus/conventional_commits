# frozen_string_literal: true

module ConventionalCommits
  # Works out the next release version from the commits since the latest version tag, using the
  # `release.rules` of the configuration: each commit's type (aliases included) maps to a bump,
  # and the biggest bump wins. A breaking change (`type!:` or a `BREAKING CHANGE:` footer) uses
  # the rule for the `breaking` type.
  class NextVersionCalculator
    VERSION_TAG = /\Av?\d+\.\d+\.\d+\z/
    SUBJECT = /\A(?<type>[A-Za-z]+)(?:\([^)]*\))?(?<breaking>!)?:/
    BREAKING_FOOTER = /^BREAKING[ -]CHANGE:/
    BREAKING_TYPE = "breaking"
    BUMPS = %w[none patch minor major].freeze

    attr_reader :git, :reader

    def initialize(git: Git.new, reader: Configuration::MainConfigurationReader.new)
      @git = git
      @reader = reader
    end

    # The next version as "X.Y.Z", `initial` when there is no version tag yet, or nil when no
    # commit since the latest tag calls for a release.
    def next_version(cfg_path: Configuration::DEFAULT_CONFIGURATION_PATH, initial: "0.1.0")
      tag = latest_version_tag
      return initial if tag.nil?

      config = reader.get_configuration(path: cfg_path)
      bumps = git.commit_messages_since(tag).map { |message| bump_for(message, config) }
      bumped(tag, bumps.max_by { |bump| BUMPS.index(bump) } || "none")
    end

    private

    def latest_version_tag
      git.tags.grep(VERSION_TAG).max_by { |tag| Gem::Version.new(tag.delete_prefix("v")) }
    end

    def bump_for(message, config)
      subject = SUBJECT.match(message.lines.first.to_s.strip)
      return "none" if subject.nil?

      if subject[:breaking] || message.match?(BREAKING_FOOTER)
        rule_bump(BREAKING_TYPE, config) || type_bump(subject[:type], config)
      else
        type_bump(subject[:type], config)
      end
    end

    def type_bump(type, config)
      rule_bump(main_type(type.downcase, config), config) || "none"
    end

    def rule_bump(type, config)
      rule = config.release.rules.find do |candidate|
        candidate.types.map { |rule_type| main_type(rule_type.to_s, config) }.include?(type)
      end
      rule && validated(rule.version)
    end

    # Rule types and commit types may be aliases ("feature", "ref"); both sides compare as the
    # configured main type. `breaking` and unknown types stay as they are.
    def main_type(type, config)
      main = config.type.main_type(type)
      main.to_s.empty? ? type : main
    end

    def validated(bump)
      raise GenericError, "Unknown release version '#{bump}', expected one of #{BUMPS}" unless BUMPS.include?(bump)

      bump
    end

    def bumped(tag, bump)
      return nil if bump == "none"

      major, minor, patch = tag.delete_prefix("v").split(".").map(&:to_i)
      case bump
      when "major" then "#{major + 1}.0.0"
      when "minor" then "#{major}.#{minor + 1}.0"
      else "#{major}.#{minor}.#{patch + 1}"
      end
    end
  end
end
