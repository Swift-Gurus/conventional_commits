# frozen_string_literal: true

module ConventionalCommits
  module Configuration
    # Configuration for branch name policies
    class BranchConfiguration
      attr_reader :ticket_prefix, :lowercase, :pattern

      def initialize(options = {})
        @ticket_prefix = options["ticket_prefix"] || ""
        @lowercase = options["lowercase"] || true
        @pattern = options["pattern"] || "<type>/<ticket>/<description>"
      end
    end
  end
end
