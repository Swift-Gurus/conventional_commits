# frozen_string_literal: true

require "fileutils"

module ConventionalCommits
  module Configuration
    class HooksInstaller
      def install_prepare_commit_msg
        cmd = (common_hooks + [
          cli_command(prepare_commit_cli)
        ])
              .join("\n")
        create_file_and_make_executable(path: "prepare-commit-msg", data: cmd)
      end

      def install_pre_commit
        cmd = common_hooks
              .join("\n")
        create_file_and_make_executable(path: "pre-commit", data: cmd)
      end

      def install_commit_msg
        cmd = (common_hooks + [cli_command(validate_commit_msg)]).join("\n")
        create_file_and_make_executable(path: "commit-msg", data: cmd)
      end

      def install_all
        install_pre_commit
        install_commit_msg
        install_prepare_commit_msg
      end

      def create_file_and_make_executable(path:, data:)
        File.create_directory(path: hook_directory)
        full_path = "#{hook_directory}/#{path}"
        File.create_new_file_with_data(full_path, data)
        FileUtils.chmod("+x", full_path)
      end

      def initial_lines
        [start_line,
         ruby_eval]
      end

      def hook_directory
        ".git/hooks"
      end

      def common_hooks
        initial_lines +
          [
            cli_command("validate_branch_name")
          ]
      end

      def cli_command(cmd)
        "bundle exec conventional_commit #{cmd}"
      end

      def ruby_eval
        "eval \"$(rbenv init -)\""
      end

      def start_line
        "#!/bin/sh"
      end

      def prepare_commit_cli
        "prepare_commit_msg --msg_path $1"
      end

      def validate_commit_msg
        "validate_commit_msg --msg_path $1"
      end
    end
  end
end
