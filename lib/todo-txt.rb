# Require all files in the main lib directory
Dir[File.dirname(__FILE__) + '/todo-txt/*.rb'].each do |file|
  require file
end

