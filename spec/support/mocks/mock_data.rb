# frozen_string_literal: true

module Support
  module Mocks
    class MockData
      attr_accessor :directory, :file, :branch_name, :configuration, :working_directory

      def initialize
        @working_directory = ""
        @directory = ".conventional_commits/"
        @file = "config.yml"
        @branch_name = "feature 1235 build a new feature"
        @configuration = FileMockOperations.read_file(path: "spec/support/mocks/config_mock.yml")
      end

      def full_path
        "#{full_directory}#{file}"
      end

      def expected_commit_message
        "feat: build a new feature\n\n[Describe your work, and put an empty string after]\n\nRef: #JIRA1235"
      end

      def expected_branch_name
        "feature/1235/build-a-new-feature"
      end

      def full_directory
        return directory if working_directory.empty?

        "#{working_directory}/#{directory}"
      end
    end
  end
end
