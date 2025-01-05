Gem::Specification.new do |s|
    s.name        = 'simple-openai-client'
    s.version     = '1.0.2'
    s.date        = '2025-01-05'
    s.summary     = "Very simple Ruby library for operating OpenAI API for building Agents."
    s.description = "Very simple Ruby library for operating OpenAI API for building Agents."
    s.authors     = ["Leandro Daniel Sardi"]
    s.email       = 'leandro@massprospecting.com'
    s.files       = [
      'lib/simple-openai-client.rb',
      'simple-openai-client.gemspec'
    ]
    s.homepage    = 'https://github.com/leandrosardi/simple-openai-client'
    s.license     = 'MIT'
    s.add_runtime_dependency 'uri', '~> 0.11.2', '>= 0.11.2'
    s.add_runtime_dependency 'net-http', '~> 0.2.0', '>= 0.2.0'
    s.add_runtime_dependency 'json', '~> 2.6.3', '>= 2.6.3'
    s.add_runtime_dependency 'blackstack-core', '~> 1.2.15', '>= 1.2.15'
    #s.add_runtime_dependency 'selenium-webdriver', '~> 4.10.0', '>= 4.10.0'
    #s.add_runtime_dependency 'watir', '~> 7.3.0', '>= 7.3.0'
    #s.add_runtime_dependency 'sequel', '~> 5.75.0', '>= 5.75.0'
    s.add_runtime_dependency 'colorize', '~> 0.8.1', '>= 0.8.1'
    s.add_runtime_dependency 'simple_cloud_logging', '~> 1.2.2', '>= 1.2.2'
end