# frozen_string_literal: true

module ConventionalCommits
  module Configuration
    # Configuration for branch name policies
    class ReleaseConfiguration
      attr_reader :rules

      def initialize(options = {})
        @rules = (options["rules"] || []).map { |options| ReleaseRule.new(options) }
      end
    end
  end
end
