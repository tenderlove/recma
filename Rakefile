require 'rubygems'
require 'hoe'

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "lib")

require 'rkelly/constants'

GENERATED_PARSER = "lib/rkelly/generated_parser.rb"

Hoe.new('rkelly', RKelly::VERSION) do |p|
  p.rubyforge_name  = 'rkelly'
  p.author          = 'Aaron Patterson'
  p.email           = 'aaronp@rubyforge.org'
  p.summary         = "RKelly parses JavaScript and returns a parse tree suitable for feeding to Ruby2Ruby."
  p.description     = p.paragraphs_of('README.txt', 3).join("\n\n")
  p.url             = p.paragraphs_of('README.txt', 1).first.strip
  p.changes         = p.paragraphs_of('CHANGELOG.txt', 0..2).join("\n\n")
  p.extra_deps      = ['ruby2ruby']
end

file GENERATED_PARSER => "lib/parser.y" do |t|
  if ENV['DEBUG']
    sh "racc -g -v -o #{t.name} #{t.prerequisites.first}"
  else
    sh "racc -o #{t.name} #{t.prerequisites.first}"
  end
end

task :parser => GENERATED_PARSER

# make sure the parser's up-to-date when we test
Rake::Task[:test].prerequisites << :parser
Rake::Task[:check_manifest].prerequisites << :parser
