# frozen_string_literal: true

module ConventionalCommits
  module Configuration
    DEFAULT_CONFIGURATION_PATH = ".conventional_commits/config.yml"
    DEFAULT_COMMIT_MSG_PATH = ".git/COMMIT_EDITMSG"
    DEFAULT_COMMIT_BODY_TEMPLATE = "[Describe your work, and put an empty string after]"
    MAX_ELEMENTS_IN_PATTERN = 4
    # Messages git writes itself for merges and squashes; hooks receive them and leave them as is.
    GIT_GENERATED_MESSAGE_FILES = %w[MERGE_MSG SQUASH_MSG].freeze

    def self.git_generated_message?(path)
      GIT_GENERATED_MESSAGE_FILES.include?(File.basename(path.to_s))
    end
  end
end
