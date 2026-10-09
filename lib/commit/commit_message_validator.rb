# frozen_string_literal: true

module ConventionalCommits
  class CommitMessageValidator
    def validate_commit_msg_from_file(commit_msg_path: Configuration::DEFAULT_COMMIT_MSG_PATH,
                                      cfg_path: Configuration::DEFAULT_CONFIGURATION_PATH)
      return if Configuration.git_generated_message?(commit_msg_path)

      parser = CommitMessageParser.new
      validate(parser.message_components(commit_msg_path:, cfg_path:))
    end

    def validate_commit_msg(message:, cfg_path: Configuration::DEFAULT_CONFIGURATION_PATH)
      parser = CommitMessageParser.new
      validate(parser.message_components_from_string(commit_msg: message, cfg_path:))
    end

    private

    def validate(components)
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
