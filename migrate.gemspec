lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'version'

Gem::Specification.new do |spec|

  spec.name          = "migrate"
  spec.version       = Migrate::VERSION
  spec.authors       = [ "Apollo Akora" ]
  spec.email         = [ "apolloakora@gmail.com" ]

  spec.summary       = %q{this migrate cli copies git repositories from bitbucket to github.}
  spec.description   = %q{migrate is a command line tool that copies git repositories from bitbucket to github.}
  spec.homepage      = "https://github.com/devops4me/bitbucket-github-migration"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = "bin"
  spec.executables   = [ 'migrate' ]
  spec.require_paths = ["lib"]
  spec.required_ruby_version = '>= 2.5.1'

  spec.add_dependency 'thor',    '~> 0.20'
  spec.add_dependency 'inifile', '~> 3.0'
  spec.add_dependency 'octokit', '~> 4.14'
  spec.add_dependency 'roo', '~> 2.8.3'

end
