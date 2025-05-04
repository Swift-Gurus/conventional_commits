# frozen_string_literal: true

module ConventionalCommits
  class CommitMessageValidator
    def validate_commit_msg_from_file(commit_msg_path: Configuration::DEFAULT_COMMIT_MSG_PATH,
                                      cfg_path: Configuration::DEFAULT_CONFIGURATION_PATH)
      return if commit_msg_path != Configuration::DEFAULT_COMMIT_MSG_PATH
      parser = CommitMessageParser.new
      components = parser.message_components(commit_msg_path:, cfg_path:)

      raise GenericError, "The Message is Invalid" if components.empty?

      if components[:body].include?(Configuration::DEFAULT_COMMIT_BODY_TEMPLATE)
        raise GenericError,
              "Body contains template"
      end

      puts "Commit message is valid"
      true
    end
  end
end
