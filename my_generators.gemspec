Gem::Specification.new do |s|
  s.name        = "my_generators"
  s.version     = "0.4.6"
  s.author      = "@alobato"
  s.email       = "@alobato"
  s.homepage    = "http://github.com/alobato/my_generators"
  s.summary     = "A collection of useful Rails generator scripts."
  s.description = "A collection of useful Rails generator scripts."

  s.files        = Dir["{lib}/**/*", "[A-Z]*"]
  s.require_path = "lib"

  s.rubyforge_project = s.name
  s.required_rubygems_version = ">= 1.3.4"
end
