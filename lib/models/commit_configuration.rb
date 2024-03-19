# frozen_string_literal: true

module ConventionalCommits
  module Configuration
    # Configuration for branch name policies
    class CommitConfiguration
      attr_reader :ticket_prefix, :lowercase, :include_ticket_number

      def initialize(ticket:, lowercase:, include_ticket_number:)
        @ticket_prefix = ticket
        @lowercase = lowercase
        @include_ticket_number = include_ticket_number
      end
    end
  end
end
