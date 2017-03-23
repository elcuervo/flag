Gem::Specification.new do |s|
  s.name              = "flag"
  s.version           = "1.0.0"
  s.summary           = "Simple feature flags"
  s.description       = "Feature flags for the humans and the coders"
  s.authors           = ["elcuervo"]
  s.licenses          = ["MIT", "HUGWARE"]
  s.email             = ["elcuervo@elcuervo.net"]
  s.homepage          = "http://github.com/elcuervo/flag"
  s.files             = `git ls-files`.split("\n")
  s.test_files        = `git ls-files test`.split("\n")

  s.add_dependency("redic", "~> 1.5.0")
  s.add_development_dependency("cutest", "~> 1.2.3")
end
