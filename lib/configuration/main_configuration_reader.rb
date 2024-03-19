# frozen_string_literal: true

require "yaml"
module ConventionalCommits
  module Configuration
    class MainConfigurationReader
      def get_configuration(path: Configuration::DEFAULT_CONFIGURATION_PATH)
        raise GenericError, "Path is empty" if path.empty?
        raise GenericError, "File not found" unless File.exist?(path)

        file = File.open(path)
        config = YAML.load(file)
        MainConfiguration.new(config)
      end
    end
  end
end

module ConventionalCommits
  class GenericError < StandardError
    def initialize(msg = "This is a custom exception", exception_type = "custom")
      @exception_type = exception_type
      super(msg)
    end
  end
end
