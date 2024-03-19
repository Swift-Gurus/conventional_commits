# frozen_string_literal: true

module ConventionalCommits
  module Configuration
    # Configuration for branch name policies
    class MainConfiguration
      attr_reader :release,
                  :branch,
                  :type

      def initialize(options = {})
        @release = ReleaseConfiguration.new(options["release"] || {})
        @branch = BranchConfiguration.new(options["branch"] || {})
        @type = TypeConfiguration.new(options["type"] || {})
      end
    end
  end
end
