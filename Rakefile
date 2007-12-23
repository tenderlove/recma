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
  p.clean_globs     = [GENERATED_PARSER]
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

desc "Create a new node"
task :new_node do
  filename = ENV['NODE']
  raise "invalid node name" if !filename

  classname = nil
  if filename =~ /[A-Z]/
    classname = filename
    filename = filename.gsub(/([A-Z])/) { |x| "_#{x.downcase}" }.gsub(/^_/, '')
  end

  full_file = "lib/rkelly/nodes/#{filename}.rb"
  test_file = "test/test_#{filename}.rb"
  puts "writing: #{full_file}"
  File.open(full_file, 'wb') { |f|
    f.write <<-END
module RKelly
  module Nodes
    class #{classname} < Node
    end
  end
end
    END
  }
  puts "adding to nodes include"
  File.open("lib/rkelly/nodes.rb", 'ab') { |f|
    f.puts "require 'rkelly/nodes/#{filename}'"
  }

  puts "writing test case: #{test_file}"
  File.open(test_file, 'wb') { |f|
    f.write <<-END
require File.dirname(__FILE__) + "/helper"

class #{classname}Test < NodeTestCase
  def test_failure
    assert false
  end
end
    END
  }
end
