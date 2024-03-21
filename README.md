# ConventionalCommits

This gem contains several tools to help enforce conventional commits practices.
It contains CLI as well as Modules that you can you for your own use cases.


## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add conventional_commits

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install conventional_commits

## Usage

Be mindful that this gem is mostly made for a specific set of practices. The idea is a team is agreed on specific branch name practices. This will help automating commits and templates thus helping developer to avoid redundant work.

For easy start you can create a file `.conventional_commits/config.yml` with the next structure 
run hooks installer by calling:

    $ conventional_commits install_hooks

```yaml
branch:
  lowercase: true
  ticket_prefix: JIRA
  pattern: <type>/<ticket>/<description>
type:
  feat: [ feature, feat ]
  fix: [ bug, bugfix, fix ]
  ci: [ ci ]
  refactor: [ ref, refactor, refactoring ]
  doc: [ doc, doc, documentation ]
release:
  rules:
    - types:
        - ref
        - fix
      version: patch
    - types:
        - feature
      version: patch
    - type: breaking
      version: major

```

### Options 
- `lowercase` - will make sure that the branch name is in lowercase when cli `conventional_commit branch <NAME>` is called
to create a new branch
- `ticket_prefix` - is used to append prefix to the commit message at the footer
- `pattern` - is used to define the separators between in future it will be used to define the order as well
- `type` - is used for mapping combination of short names for the type of request. Helps to avoid inconsistency.

### Release
Not implemented yet. It will contain tools to increment version number based on the rules


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Swift-Gurus/conventional_commits.
