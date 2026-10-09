# frozen_string_literal: true

module ConventionalCommits
  module Configuration
    # A release rule: which commit types produce which version bump
    class ReleaseRule
      attr_reader :types, :version

      # Accepts both `types: [..]` and the singular `type: ..` used for the breaking rule.
      def initialize(options = {})
        @types = Array(options["types"] || options["type"])
        @version = options["version"] || "none"
      end
    end
  end
end
