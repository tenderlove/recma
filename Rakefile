require 'rubygems'
require 'rake/testtask'

GENERATED_PARSER = "lib/rkelly/generated_parser.rb"

file GENERATED_PARSER => "lib/parser.y" do |t|
  if ENV['DEBUG']
    sh "racc -g -v -o #{t.name} #{t.prerequisites.first}"
  else
    sh "racc -o #{t.name} #{t.prerequisites.first}"
  end
end

task :parser => GENERATED_PARSER

Rake::TestTask.new(:tests) do |t|
  t.libs = [ "lib", "."]
  t.test_files = FileList['test/test*.rb', 'test/*/test_*.rb']
  t.verbose = true
end

task :tests => :parser


