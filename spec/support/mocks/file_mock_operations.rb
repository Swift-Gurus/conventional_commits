# frozen_string_literal: true

require "pathname"
require "helpers/file_extension"
require "fileutils"

module Support
  module Mocks
    # def file_operations
    #   FileMockOperations.new
    # end

    # def data_mock
    #   MockData.new
    # end

    class FileMockOperations
      attr_reader :mocks

      def initialize
        @mocks = MockData.new
      end

      def clean_up_mocks
        delete_file

        delete_directory(path: mocks.full_directory)
      end

      def write_mock_data_to_file(path: mocks.full_path, data: mocks.configuration)
        pn = Pathname.new(path)
        b = pn.dirname
        File.create_directory(path: b)
        File.write_to_file(path, data)
      end

      def delete_directory(path: mocks.full_directory)
        File.delete_directory(path:)
      end

      def delete_file(path: mocks.full_path)
        File.delete_file(path:)
      end

      def self.read_file(path: string)
        File.read_file(path)
      end

      def update_pattern_in_config(_new_pattern)
        config = YAML.load(mocks.configuration)
        config["branch"]["pattern"] = _new_pattern
        write_mock_data_to_file(data: YAML.dump(config))
      end
    end
  end
end
