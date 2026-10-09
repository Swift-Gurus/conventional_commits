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
      source = options["source"] || ENV["PRE_COMMIT_COMMIT_MSG_SOURCE"] || ""
      msg_path = options["msg_path"] || Configuration::DEFAULT_COMMIT_MSG_PATH
      cfg_path = options["cfg_path"] || Configuration::DEFAULT_CONFIGURATION_PATH

      return if Configuration.git_generated_message?(msg_path)

      generator = ConventionalCommits::CommitMessageGenerator.new
      unless generator.should_preserve_original_message(source:)
        puts "Generating message"
        name = generator.prepare_message_template_for_type(type: source, cfg_path:, msg_file_path: msg_path)
        File.write_to_file(msg_path, name)
      end
    rescue StandardError => e
      raise Thor::Error, e.message
    end

    desc "validate_branch", "validates if the branch conforms to the rules"
    option :cfg_path, type: :string, required: false
    option :branch, type: :string, required: false,
                    desc: "Branch to validate; defaults to the current branch, then $GITHUB_HEAD_REF"
    def validate_branch_name
      cfg_path = options["cfg_path"] || Configuration::DEFAULT_CONFIGURATION_PATH
      generator = ConventionalCommits::BranchNameGenerator.new
      generator.is_valid_branch(branch_name_to_validate, path: cfg_path.strip)
    rescue StandardError => e
      raise Thor::Error, e.message
    end

    desc "validate_commit_msg", "validates if the commit message conforms to the rules"
    option :msg_path, type: :string, required: false
    option :msg, type: :string, required: false, desc: "Message text to validate instead of a file"
    option :cfg_path, type: :string, required: false
    def validate_commit_msg
      msg_path = options["msg_path"] || Configuration::DEFAULT_COMMIT_MSG_PATH
      cfg_path = options["cfg_path"] || Configuration::DEFAULT_CONFIGURATION_PATH
      validator = ConventionalCommits::CommitMessageValidator.new

      if options["msg"]
        validator.validate_commit_msg(message: options["msg"], cfg_path:)
      else
        validator.validate_commit_msg_from_file(commit_msg_path: msg_path, cfg_path:)
      end
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

    no_commands do
      # A detached HEAD (e.g. a CI checkout of a pull request) has no current branch, so fall
      # back to the pull request's head branch that GitHub Actions provides.
      def branch_name_to_validate
        name = [options["branch"], ConventionalCommits::Git.new.current_branch_name, ENV["GITHUB_HEAD_REF"]]
               .map { |candidate| candidate.to_s.strip }
               .find { |candidate| !candidate.empty? }
        raise GenericError, "Cannot determine the branch name (HEAD is detached); pass --branch" if name.nil?

        name
      end
    end
  end
end
