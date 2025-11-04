# frozen_string_literal: true

require_relative 'lib/devicecheck/version'

Gem::Specification.new do |spec|
  spec.name = 'devicecheck'
  spec.version = Devicecheck::VERSION
  spec.authors = ['Fabricio Chalub']
  spec.email = ['opensource@catawiki.nl']
  spec.license = 'MIT'
  spec.homepage = 'https://github.com/catawiki/devicecheck-ruby'
  spec.description = 'Pure Ruby implementation of the Apple App Attestation server side verifier'
  spec.summary = 'Apple App Attestation (aka DeviceCheck) support for Ruby.'
  spec.required_ruby_version = '>= 3.2'

  spec.metadata = {
    'bug_tracker_uri' => 'https://github.com/catawiki/devicecheck-ruby/issues',
    'changelog_uri' => 'https://github.com/catawiki/devicecheck-ruby/blob/main/CHANGELOG.md',
    'documentation_uri' => 'https://rubydoc.info/github/catawiki/devicecheck-ruby',
    'source_code_uri' => 'https://github.com/catawiki/devicecheck-ruby',
    'rubygems_mfa_required' => 'true'
  }

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'base64', '~> 0.3.0'
  spec.add_dependency 'cbor', '~> 0.5.9'
  spec.add_dependency 'openssl', '~> 3'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata['rubygems_mfa_required'] = 'true'
end
