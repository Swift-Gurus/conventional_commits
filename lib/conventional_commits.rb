# frozen_string_literal: true

require_relative "conventional_commits/version"
require_relative "configuration"
module ConventionalCommits
  class Error < StandardError; end
  def self.get_branch_components(branch_name)
    BranchNameGenerator.new.branch_name_components(branch_name)
  end
end
