Gem::Specification.new do |s|
  s.name = 'todo-txt'
  s.version = '0.9'
  s.authors = ["Sam Rose"]
  s.email = %q{samwho@lbak.co.uk}
  s.summary = %q{A client library for parsing todo.txt files.}
  s.homepage = %q{http://github.com/samwho/todo-txt-gem}
  s.description = %q{Allows for simple parsing of todo.txt files, as per Gina Trapani's todo.txt project.}
  s.required_ruby_version = '>= 2.0'
  s.license = 'GPL-2'
  s.files = `git ls-files`.split(/\n/)
end
