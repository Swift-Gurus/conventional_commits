# frozen_string_literal: true

module ConventionalCommits
  class Git
    def current_branch_name
      run_system_command "git symbolic-ref --short HEAD"
    end

    def set_commit_msg(_msg)
      run_system_command "git symbolic-ref --short HEAD"
    end

    def tags
      run_system_command("git tag --list").split("\n").map(&:strip).reject(&:empty?)
    end

    # Full messages of the commits reachable from HEAD but not from `ref`, newest first.
    def commit_messages_since(ref)
      run_system_command("git log --format=%B%x00 #{ref}..HEAD")
        .split("\x00").map(&:strip).reject(&:empty?)
    end

    def run_system_command(_cmd)
      Open3.popen3(_cmd) { |_stdin, stdout, _stderr, _wait_thr| stdout.read }
    end
  end
end
