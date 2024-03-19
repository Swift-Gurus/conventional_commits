# frozen_string_literal: true

module ConventionalCommits
  module Configuration
    # Configuration for branch name policies
    class ReleaseRule
      attr_reader :types, :version

      def initialize(options = {})
        @types = options["types"] || []
        @version = options["version"] || "none"
      end
    end
  end
end
