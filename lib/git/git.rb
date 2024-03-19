# frozen_string_literal: true

module ConventionalCommits
  class Git
    def current_branch_name
      run_system_command "git symbolic-ref --short HEAD"
    end

    def set_commit_msg(_msg)
      run_system_command "git symbolic-ref --short HEAD"
    end

    def run_system_command(_cmd)
      Open3.popen3(_cmd) { |_stdin, stdout, _stderr, _wait_thr| stdout.read }
    end
  end
end
