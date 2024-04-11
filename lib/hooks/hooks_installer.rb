# frozen_string_literal: true

require "fileutils"

module ConventionalCommits
  module Configuration
    class HooksInstaller
      def install_prepare_commit_msg
        cmd = (common_hooks + [
          cli_command(prepare_commit_cli)
        ])
        create_file_and_make_executable(path: "prepare-commit-msg", commands: cmd)
      end

      def install_pre_commit
        cmd = common_hooks
        create_file_and_make_executable(path: "pre-commit", commands: cmd)
      end

      def install_commit_msg
        cmd = (common_hooks + [cli_command(validate_commit_msg)])
        create_file_and_make_executable(path: "commit-msg", commands: cmd)
      end

      def install_all
        install_pre_commit
        install_commit_msg
        install_prepare_commit_msg
      end

      def create_file_and_make_executable(path:, commands:)
        File.create_directory(path: hook_directory)
        full_path = "#{hook_directory}/#{path}"
        filtered_commands = filter_existed_values_in_script(path: full_path, commands:)
        data = filtered_commands.join("\n")
        File.create_or_add_to_file_data(full_path, data)
        FileUtils.chmod("+x", full_path)
      end

      def filter_existed_values_in_script(path:, commands:)
        return commands unless File.exist?(path)

        data = File.read_file(path) || ""
        commands.reject { |cmd| data.include?(cmd) }
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
        "bundle exec conventional_commits #{cmd}"
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
