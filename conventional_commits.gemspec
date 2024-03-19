# frozen_string_literal: true

require_relative "lib/conventional_commits/version"

Gem::Specification.new do |spec|
  spec.name = "conventional_commits"
  spec.version = ConventionalCommits::VERSION
  spec.authors = "Swift-Gurus"
  spec.email = "alexei.hmelevski@gmail.com"

  spec.summary = "Make your commit unified."
  spec.description = "Enforces conventional commits specs."
  spec.homepage = "https://github.com/Swift-Gurus/conventional_commits"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Swift-Gurus/conventional_commits"
  spec.metadata["changelog_uri"] = "https://github.com/Swift-Gurus/conventional_commits"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "thor"
  spec.add_dependency "yaml"
  spec.add_dependency "open3"

  spec.add_development_dependency "aruba"
  spec.add_development_dependency "cucumber"
  spec.add_development_dependency "simplecov"
end
