Gem::Specification.new do |s|
  s.name = %q{todo-txt}
  s.version = "0.1"
  s.date = %q{2011-08-19}
  s.authors = ["Sam Rose"]
  s.email = %q{samwho@lbak.co.uk}
  s.summary = %q{A client library for parsing todo.txt files.}
  s.homepage = %q{http://lbak.co.uk}
  s.description = %q{Allows for simple parsing of todo.txt files, as per Gina Trapani's todo.txt project.}
  s.required_ruby_version = '>= 1.9.2'
  s.license = 'GPL-2'

  # Add all files to the files parameter.
  s.files = []
  Dir["**/*.*"].each { |path| s.files.push path }
end
