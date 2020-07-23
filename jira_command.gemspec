require_relative 'lib/jira_command/version'

Gem::Specification.new do |spec|
  spec.name          = 'jira_command'
  spec.version       = JiraCommand::VERSION
  spec.authors       = ['shengbo.xu']
  spec.email         = ['shengbo.xu@xincere.jp']

  spec.summary       = 'jira cli'
  spec.description   = 'jira cli tool'
  spec.homepage      = 'https://github.com/xincere-inc/jira_command'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  # spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/xincere-inc/jira_command'
  spec.metadata['changelog_uri'] = 'https://github.com/xincere-inc/jira_command'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'faraday'
  spec.add_dependency 'terminal-table'
  spec.add_dependency 'thor'
  spec.add_dependency 'tty-prompt'
end
