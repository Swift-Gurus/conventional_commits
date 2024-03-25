# frozen_string_literal: true

module ConventionalCommits
  class CommitMessageParser
    def message_components(commit_msg_path: Configuration::DEFAULT_COMMIT_MSG_PATH,
                           cfg_path: Configuration::DEFAULT_CONFIGURATION_PATH)
      raise GenericError, "Commit Message File is not created" unless File.exist?(commit_msg_path)

      data = File.read_file(commit_msg_path)
      message_components_from_string(commit_msg: data.to_s, cfg_path:)
    end

    def message_components_from_string(commit_msg: "",
                                       cfg_path: Configuration::DEFAULT_CONFIGURATION_PATH)
      msg_components = commit_msg.split "\n"
      if msg_components.length < 5
        raise GenericError, "Commit Message Doesnt respect the spec, expect to have subject, body and footer"
      end

      main_config = Configuration::MainConfigurationReader.new.get_configuration(path: cfg_path)

      subject_components = msg_components[0].split(":").map(&:strip)
      if subject_components.length < 2
        raise raise GenericError,
                    "Subject doesnt respect the format"
      end
      scope_split = subject_components[0].split(/\(([^)]+)\)/)
      components = { scope: nil, type: "", title: "", body: "" }
      components[:scope] = scope_split.length > 1 ? scope_split[1] : nil
      components[:type] = scope_split[0]
      components[:title] = subject_components[1]
      components[:body] = msg_components[2]

      unless main_config.type.is_allowed(components[:type])
        raise raise GenericError,
                    "Commit Type is not in the config yaml"
      end

      components
    end
  end
end
