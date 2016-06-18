desc 'Run bacon tests'
task default: [:test]

desc 'Build yard docs'
task :doc do
  exec 'yard'
end

desc 'Show list of undocumented modules/classes/methods'
task :nodoc do
  exec 'yard stats --list-undoc'
end

desc 'Run bacon tests'
task :test do
  exec 'bacon spec/racket_registry.rb'
end
