Gem::Specification.new do |s|
  s.name        = 'poof'
  s.version     = '0.0.0.dev'
  s.date        = '2015-05-08'
  s.summary     = "Automatically cleanup and destroy ActiveRecord objects created during tests."
  s.description = "An alternative to DatabaseCleaner for automatically ensuring that objects created during
                  tests are removed from the database."
  s.authors     = ["Courtland Caldwell"]
  s.email       = 'courtland@mattermark.com'
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.homepage    =
      'https://github.com/Referly/poof'
  s.add_runtime_dependency "activerecord", "~> 4.1", ">= 4.1.5"
  s.add_development_dependency "rake", "~> 10.3"
  s.add_development_dependency "simplecov", "~> 0.10"
  s.add_development_dependency "yard", "~> 0.8"
  s.add_development_dependency "rspec", "~> 3.2"
  s.add_development_dependency "byebug", "~> 4.0"
  s.license     = "MIT"
end