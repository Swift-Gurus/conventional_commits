# frozen_string_literal: true

module ConventionalCommits
  module Configuration
    class BranchConfigurationReader
      def get_configuration(path: Configuration::DEFAULT_CONFIGURATION_PATH)
        reader = MainConfigurationReader.new
        config = reader.get_configuration(path:)
        config.branch
      end
    end
  end
end
