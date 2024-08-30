# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'test_helpers/version'

Gem::Specification.new do |spec|
  spec.name          = 'test_helpers'
  spec.version       = TestHelpers::VERSION.version
  spec.authors       = ['Raseel Mohamed']
  spec.email         = ['mraseelak@gmail.com']

  spec.summary       = 'Gem to help in Testing BIAD applications'
  spec.description   = 'This gem will collect and act as a single resource for all the helper methods used in testing. This provides advantage of reusability to all testing. '
  spec.homepage      = 'https://github.com/mraseelak/helpersDeTesting'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 3.0  is required to protect against ' \
      'public gem pushes.'
  end
  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'awesome_print', '~> 1.9'
  spec.add_development_dependency 'bundler', '~> 2.5'
  spec.add_development_dependency 'byebug', '~> 11.1'
  spec.add_development_dependency 'pry', '~> 0.14'
  spec.add_development_dependency 'rake', '~> 13.2'
  spec.add_development_dependency 'rspec', '~> 3.10'
  spec.add_development_dependency 'rubocop', '~> 1.63'
  spec.add_development_dependency 'simplecov', '~> 0.22'
  spec.add_development_dependency 'webmock', '~> 3.8', '>= 3.8.3'
  spec.add_dependency 'aws-sdk-dynamodb', '~>1'
  spec.add_dependency 'aws-sdk-iam', '~>1'
  spec.add_dependency 'aws-sdk-lambda', '~> 1'
  spec.add_dependency 'aws-sdk-qldb', '~>1'
  spec.add_dependency 'aws-sdk-qldbsession', '~>1'
  spec.add_dependency 'aws-sdk-s3', '~>1'
  spec.add_dependency 'aws-sdk-secretsmanager', '~>1'
  spec.add_dependency 'aws-sdk-sqs', '~>1'
  spec.add_dependency 'commander', '~>5.0'
  spec.add_dependency 'httparty', '>= 0.21.0'
  spec.add_dependency 'mail', '~>2.7.1'
  spec.add_dependency 'mongo', '~> 2.6', '>= 2.6.2'
  spec.add_dependency 'nokogiri', '~> 1.16'
  spec.add_dependency 'rainbow', '~> 3.0'
  spec.add_dependency 'recursive-open-struct', '~> 1.1'
  spec.add_dependency 'rest-client', '~> 2.1'
  spec.add_dependency 'roo', '~>2.7'
end
