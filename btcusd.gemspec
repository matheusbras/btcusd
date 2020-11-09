require_relative 'lib/btcusd/version'

Gem::Specification.new do |spec|
  spec.name          = "btcusd"
  spec.version       = Btcusd::VERSION
  spec.authors       = ["Matheus Bras"]
  spec.email         = ["bras.matheus@gmail.com"]

  spec.summary       = %q{Write a short summary, because RubyGems requires one.}
  spec.description   = %q{Write a longer description or delete this line.}
  spec.homepage      = "http://messari.io"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.executables   = ['btcusd']
  spec.require_paths = ["lib"]
end
