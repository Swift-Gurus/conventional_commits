# frozen_string_literal: true

require_relative "conventional_commits/version"
require_relative "configuration/branch_configuration_reader"
require_relative "branch/branch_name_generator"
require_relative "configuration"
require_relative "configuration/main_configuration_reader"
require_relative "models/main_configuration"
require_relative "models/release_configuration"
require_relative "models/release_rule"
require_relative "models/branch_configuration"
require_relative "models/type_configuration"
require_relative "models/commit_configuration"
module ConventionalCommits
  class Error < StandardError; end
  def self.get_branch_components(branch_name)
    BranchNameGenerator.new.branch_name_components(branch_name)
  end
end
