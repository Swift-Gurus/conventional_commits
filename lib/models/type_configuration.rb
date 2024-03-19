# frozen_string_literal: true

module ConventionalCommits
  module Configuration
    # Configuration for branch name policies
    class TypeConfiguration
      attr_reader :options

      def initialize(o = {})
        @options = o
      end

      def is_allowed(type)
        all_types.include?(type)
      end

      def main_type(_type)
        match = ""

        options.each do |key, array|
          match = key if array.include?(_type)
        end
        match
      end

      def all_types
        options.keys + options.values.flat_map { |e| e }
      end
    end
  end
end
