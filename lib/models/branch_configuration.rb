# frozen_string_literal: true

module ConventionalCommits
  module Configuration
    # Configuration for branch name policies
    class BranchConfiguration
      attr_reader :ticket_prefix, :lowercase, :pattern, :ticket, :ticket_separator

      def initialize(options = {})
        @ticket_prefix = options["ticket_prefix"] || ""
        @ticket = options["ticket"] || ""
        @ticket_separator = options["ticket_separator"] || "-"
        @lowercase = options["lowercase"] || true
        @pattern = options["pattern"] || "<scope>/<type>/<ticket>/<description>"
      end
    end
  end
end
