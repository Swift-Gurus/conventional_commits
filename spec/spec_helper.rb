# frozen_string_literal: true

require "conventional_commits"
require "configuration"
require "configuration/main_configuration_reader"
require "configuration/branch_configuration_reader"
require "models/branch_configuration"
require "models/main_configuration"
require "models/release_configuration"
require "models/release_rule"
require "aruba/rspec"
require "cli/branch_name_cli"
require "git/git"
require "helpers/file_extension"
require "branch/branch_name_generator"
require "support/mocks/mock_data"
require "support/mocks/file_mock_operations"
require "commit/commit_message_generator"
require "models/type_configuration"
require "hooks/hooks_installer"
require "commit/commit_message_parser"
require "commit/commit_message_validator"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
