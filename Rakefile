require 'rubygems'
require 'hoe'

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "lib")
require 'rkelly'

class RKellyHoe < Hoe
  def define_tasks
    super

    desc "Tag code"
    task :tag do |p|
      abort "Must supply VERSION=x.y.z" unless ENV['VERSION']
      v = ENV['VERSION'].gsub(/\./, '_')

      rf = RubyForge.new
      user = rf.userconfig['username']

      baseurl = "svn+ssh://#{user}@rubyforge.org//var/svn/#{name}"
      sh "svn cp -m 'tagged REL-#{v}' . #{ baseurl }/tags/REL-#{ v }"
    end

    desc "Branch code"
    Rake::Task.define_task("branch") do |p|
      abort "Must supply VERSION=x.y.z" unless ENV['VERSION']
      v = ENV['VERSION'].split(/\./)[0..1].join('_')

      rf = RubyForge.new
      user = rf.userconfig['username']

      baseurl = "svn+ssh://#{user}@rubyforge.org/var/svn/#{name}"
      sh "svn cp -m'branched #{v}' #{baseurl}/trunk #{baseurl}/branches/RB-#{v}"
    end
  end
end

RKellyHoe.new('rkelly', RKelly::VERSION) do |p|
  p.rubyforge_name  = 'rkelly'
  p.author          = 'Aaron Patterson'
  p.email           = 'aaronp@rubyforge.org'
  p.summary         = "RKelly parses JavaScript and returns a parse tree suitable for feeding to Ruby2Ruby."
  p.description     = p.paragraphs_of('README.txt', 3).join("\n\n")
  p.url             = p.paragraphs_of('README.txt', 1).first.strip
  p.changes         = p.paragraphs_of('CHANGELOG.txt', 0..2).join("\n\n")
  p.extra_deps      = ['ruby2ruby']
end


