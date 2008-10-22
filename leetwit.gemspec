require 'rake'

Gem::Specification.new do |s|
  s.name     = "leetwit"
  s.version  = "1.0.0"
  s.date     = "2008-10-22"
  s.summary  = "twitter client for leet users"
  s.email    = "theath@gmail.com"
  s.homepage = "http://github.com/terrbear/leetwit"
  s.description = "twitter client for leet users"
  s.has_rdoc = false
  s.authors  = ["Terry Heath"]
  s.files    = FileList[ "README.txt", "lib/*.rb", "lib/**/*.rb" "leetwit.gemspec" "bin/*"].to_a
	s.require_path = 'lib'
  s.add_dependency("twitter4r", [">= 0.3.0"])

	s.requirements << "twitter4r, 0.3.0 or later"

	s.bindir = 'bin'
	s.executables << "leetwit"
end
