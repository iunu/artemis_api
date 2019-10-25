
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "artemis_api/version"

Gem::Specification.new do |spec|
  spec.name          = "artemis_api"
  spec.version       = ArtemisApi::VERSION
  spec.authors       = ["Jamey Hampton"]
  spec.email         = ["jhampton@artemisag.com"]

  spec.summary       = %q{An API wrapper for the ArtemisAg API}
  spec.homepage      = "https://github.com/artemis-ag/artemis_api/"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
    f.match(/\.gem$/)
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "oauth2"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "activesupport"
end
