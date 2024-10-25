# frozen_string_literal: true

require_relative "conventional_commits/version"
require_relative "branch/branch_name_generator"
module ConventionalCommits
  class Error < StandardError; end
  def self.get_branch_components(branch_name)
    Configuration::BranchNameGenerator.new.branch_name_components(branch_name)
  end
end
