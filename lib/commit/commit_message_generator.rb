# frozen_string_literal: true

require "open3"
module ConventionalCommits
  class CommitMessageGenerator
    def prepare_template_message(custom_body: "", cfg_path: Configuration::DEFAULT_CONFIGURATION_PATH)
      branch_name = Git.new.current_branch_name
      main_config = Configuration::MainConfigurationReader.new.get_configuration(path: cfg_path)
      configuration = main_config.branch
      components = BranchNameGenerator.new.branch_name_components(branch_name, path: cfg_path)
      scope = components[:scope] ? "(#{components[:scope].downcase})" : ""
      type = (components[:type] || "").downcase
      ticket_number = components[:ticket_number] || ""
      description = components[:description] || ""
      description = sanitize(description)

      unless main_config.type.is_allowed(type)
        raise ConventionalCommits::GenericError,
              "The type #{type} is not allowed. Allowed types #{main_config.type.all_types}"
      end

      type = "#{main_config.type.main_type(type)}#{scope}: #{description}".strip

      ticket_ref = "#{configuration.ticket_prefix}#{configuration.ticket}#{configuration.ticket_separator}#{ticket_number}"
      body = custom_body.strip.empty? ? Configuration::DEFAULT_COMMIT_BODY_TEMPLATE : custom_body.strip
      footer = "Ref: #{ticket_ref}".strip
      "#{type}\n\n#{body}\n\n#{footer}"
    end

    def prepare_message_template_for_type(type: "",
                                          cfg_path: Configuration::DEFAULT_CONFIGURATION_PATH,
                                          msg_file_path: Configuration::DEFAULT_COMMIT_MSG_PATH)
      prepare_template_message(cfg_path:) unless should_try_to_parse_msg_from_file(source: type)

      parser = CommitMessageParser.new
      components = parser.message_components(commit_msg_path: msg_file_path, cfg_path:)
      prepare_template_message(custom_body: components[:body], cfg_path:)
    rescue StandardError
      data = File.read_file(msg_file_path).to_s
      prepare_template_message(custom_body: data, cfg_path:)
    end
    def should_try_to_parse_msg_from_file(source: "")
      skippable_sources.include?(source)
    end

    private

    def skippable_sources
      %w[message merge squash]
    end

    def sanitize(string)
      string.gsub(/-/, " ").gsub(/_/, " ")
    end
  end
end
