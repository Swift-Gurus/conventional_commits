# frozen_string_literal: true

module ConventionalCommits
  class BranchNameGenerator
    attr_reader :reader

    def initialize(reader: reader = Configuration::BranchConfigurationReader.new)
      @reader = reader
    end

    def generate_name_for(_input, path: Configuration::DEFAULT_CONFIGURATION_PATH)
      configuration = reader.get_configuration(path:)
      delimiters = find_delimiters_from_pattern(pattern: configuration.pattern)
      input_order = transform_input_using_delimiters(_input, delimiters)

      name = input_order.each_with_index.reduce("") do |acc, (e, i)|
        acc + e + (delimiters[i] || (i + 1 == input_order.length ? "" : "-"))
      end

      name.downcase if configuration.lowercase == true
    end

    def branch_name_components(_input, path: Configuration::DEFAULT_CONFIGURATION_PATH)
      configuration = reader.get_configuration(path:)
      delimiters = find_delimiters_from_pattern(pattern: configuration.pattern)
      received = _input
      modified_input = _input
      out = []
      delimiters.each do |d|
        splits = modified_input.split(d, 2)
        out.push(splits[0]) if splits.length.positive?
        modified_input = splits[1] || ""
      end
      out.push(modified_input) unless modified_input.empty?
      if delimiters.length > out.length
        raise ConventionalCommits::GenericError,
              "The branch doesnt respect the template, expect #{delimiters.length} delimiters. Received: #{received}".strip
      end

      scope_is_included = out.length == Configuration::MAX_ELEMENTS_IN_PATTERN
      idx_adj = scope_is_included ? 1 : 0
      components = { scope: nil, type: nil, ticket_number: nil, description: nil }
      components[:scope] = out.length == Configuration::MAX_ELEMENTS_IN_PATTERN ? out[0] : nil
      components[:type] = out[0 + idx_adj]
      components[:ticket_number] = out[1 + idx_adj]
      components[:description] = out[2 + idx_adj]
      components
    end

    def is_valid_branch(_input, path: Configuration::DEFAULT_CONFIGURATION_PATH)
      !branch_name_components(_input, path:).empty?
    end

    private

    def find_delimiters_from_pattern(pattern: string)
      delimiters = pattern.gsub(/<scope>/, "<replace>")
                          .gsub(/<type>/, "<replace>")
                          .gsub(/<ticket>/, "<replace>")
                          .gsub(/<description>/, "<replace>")
                          .split("<replace>")
                          .reject { |str| str.empty? == true }
      raise(GenericError, "Delimiters not found in pattern") if delimiters.empty?

      delimiters
    end

    def transform_input_using_delimiters(_input, delimiters)
      splits = _input.gsub(/_/, " ").scan(/\w+/)
      validate_delimiters(delimiters, splits.length)
      splits
    end

    def validate_delimiters(delimiters, number_of_words)
      return unless number_of_words < delimiters.length + 1

      raise(GenericError,
            "Doesnt match the pattern expect at least #{delimiters.length + 1} words")
    end
  end
end
