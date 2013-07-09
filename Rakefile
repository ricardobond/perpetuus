require "bundler/gem_tasks"
require "rspec/core/rake_task"

require 'colored'
require 'perpetuus'
require 'mg'

MG.new("perpetuus.gemspec")
RSpec::Core::RakeTask.new(:spec)

task :default => :spec
task :test => :spec

# TAREFA PARA REINSTALAR A GEM SEMPRE QUE CÓDIGO NOVO FOR INSERIDO!!!
# --- DELETAR ESTA TAREFA APÓS CONCLUIR PROJETO ---
task :reinstall do
  system 'gem uninstall perpetuus'
  system 'rake install'
end

task :teste do
  #system 'rspec spec'
  s = system 'rspec spec'
  puts s.class
  puts $?.class
  puts result=$?.success?
end

task :oi do
  while true
    if system 'rspec spec'
      puts 'oi oi oi oi'
    end
  end
end