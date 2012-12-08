Gem::Specification.new do |s|
  s.name = %q{todo-txt}
  s.version = "0.3.1"
  s.date = %q{2012-03-31}
  s.authors = ["Sam Rose"]
  s.email = %q{samwho@lbak.co.uk}
  s.summary = %q{A client library for parsing todo.txt files.}
  s.homepage = %q{http://github.com/samwho/todo-txt-gem}
  s.description = %q{Allows for simple parsing of todo.txt files, as per Gina Trapani's todo.txt project.}
  s.required_ruby_version = '>= 1.9.2'
  s.license = 'GPL-2'

  # Add all files to the files parameter.
  s.files = `git ls-files`.split /\n/
end
