# frozen_string_literal: true

require_relative 'lib/light_gpt_proxy/version'

Gem::Specification.new do |spec|
  spec.name = 'light_gpt_proxy'
  spec.version = LightGptProxy::VERSION
  spec.authors = ['Pawel Niemczyk']
  spec.email = ['pniemczyk.info@.gmail.com']

  spec.summary = 'Light proxy for ChatGPT'
  spec.description = 'Light proxy for ChatGPT'
  spec.homepage = 'https://github.com/pniemczyk/light_gpt_proxy'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.2.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.add_dependency 'faraday', '~> 2.0'
  spec.add_dependency 'hashie', '~> 5.0'
  spec.add_dependency 'json', '~> 2.6'
  spec.add_dependency 'lockbox', '~> 1.4'
  spec.add_dependency 'puma', '~> 5.0'
  spec.add_dependency 'sinatra', '~> 3.0'
  spec.add_dependency 'yaml', '~> 0.3'
end
