# frozen_string_literal: true

module ConventionalCommits
  module Configuration
    DEFAULT_CONFIGURATION_PATH = ".conventional_commits/config.yml"
    DEFAULT_COMMIT_MSG_PATH = ".git/COMMIT_EDITMSG"
    DEFAULT_COMMIT_BODY_TEMPLATE = "[Describe your work, and put an empty string after]"
    MAX_ELEMENTS_IN_PATTERN = 4
  end
end
