lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sequel-cacheable/version'

Gem::Specification.new do |gem|
  gem.name          = "sequel-cacheable"
  gem.version       = Sequel::Plugins::Cacheable::VERSION
  gem.authors       = ["Sho Kusano"]
  gem.email         = ["rosylilly@aduca.org"]
  gem.description   = %q{This plug-in caching mechanism to implement the Model of the Sequel}
  gem.summary       = %q{This plug-in caching mechanism to implement the Model of the Sequel}
  gem.homepage      = "https://github.com/rosylilly/sequel-cacheable"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'sequel', '~> 3.42'
  gem.add_dependency 'msgpack', '~> 0.5.1'
end
