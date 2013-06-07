# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'rkelly/constants'


GENERATED_PARSER = "lib/rkelly/generated_parser.rb"

Gem::Specification.new do |s|
  s.name        = "fotonauts-rkelly"
  s.version     = RKelly::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = [ 'Aaron Patterson', 'fotonauts']
  s.email       = ["aaron.patterson@gmail.com", "contact@fotonauts.com"]
  s.homepage    = "https://github.com/fotonauts/rkelly"
  s.summary     = "The RKelly library will parse JavaScript and return a parse tree."

  s.extra_rdoc_files  = Dir.glob("*.rdoc")

  s.add_development_dependency(%q<racc>, [">= 1.4.6"])

  s.rdoc_options << '--title' << 'RKelly' <<
    '--main' << 'README' <<
    '--line-numbers'

  s.required_rubygems_version = ">= 1.3.6"
  s.files        = Dir.glob("{lib}/**/*") + %w(LICENSE README.rdoc CHANGELOG.rdoc )
  s.require_path = 'lib'
end
