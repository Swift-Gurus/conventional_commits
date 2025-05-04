# frozen_string_literal: true

require "thor"

module ConventionalCommits
  class BranchNameCLI < Thor
    def self.exit_on_failure?
      true
    end

    desc "branch NAME", "formats the branch name based on the rules"
    option :cfg_path, type: :string, required: false
    def branch(_name)
      cfg_path = options["cfg_path"] || Configuration::DEFAULT_CONFIGURATION_PATH
      generator = ConventionalCommits::BranchNameGenerator.new
      generated_name = generator.generate_name_for(_name.strip, path: cfg_path.strip)
      Kernel.system("git branch #{generated_name}")
    rescue StandardError => e
      raise Thor::Error, e.message
    end

    desc "prepare_commit_msg", "Prepares commit message"
    option :msg_path, type: :string, required: false
    option :source, type: :string, required: false
    option :cfg_path, type: :string, required: false
    def prepare_commit_msg
      source = options["source"] || ""
      puts source
      msg_path = options["msg_path"] || Configuration::DEFAULT_COMMIT_MSG_PATH
      cfg_path = options["cfg_path"] || Configuration::DEFAULT_CONFIGURATION_PATH

      generator = ConventionalCommits::CommitMessageGenerator.new
      unless generator.should_try_to_parse_msg_from_file(source:)
        puts "Generating message"
        name = generator.prepare_message_template_for_type(type: source, cfg_path:, msg_file_path: msg_path)
        File.write_to_file(msg_path, name)
      end
      
    rescue StandardError => e
      raise Thor::Error, e.message
    end

    desc "validate_branch", "validates if the branch conforms to the rules"
    option :cfg_path, type: :string, required: false
    def validate_branch_name
      cfg_path = options["cfg_path"] || Configuration::DEFAULT_CONFIGURATION_PATH
      generator = ConventionalCommits::BranchNameGenerator.new
      name = ConventionalCommits::Git.new.current_branch_name
      generator.is_valid_branch(name.strip, path: cfg_path.strip)
    rescue StandardError => e
      raise Thor::Error, e.message
    end

    desc "validate_commit_msg", "validates if the branch conforms to the rules"
    option :msg_path, type: :string, required: false
    option :msg, type: :string, required: false
    option :cfg_path, type: :string, required: false
    def validate_commit_msg
      msg_path = options["msg_path"] || Configuration::DEFAULT_COMMIT_MSG_PATH
      cfg_path = options["cfg_path"] || Configuration::DEFAULT_CONFIGURATION_PATH
      validator = ConventionalCommits::CommitMessageValidator.new
      validator.validate_commit_msg_from_file(commit_msg_path: msg_path, cfg_path:)
    rescue StandardError => e
      raise Thor::Error, e.message
    end

    desc "install_hooks", "install all git hooks"
    def install_hooks
      installer = ConventionalCommits::Configuration::HooksInstaller.new
      installer.install_all
    rescue StandardError => e
      raise Thor::Error, e.message
    end
  end
end
