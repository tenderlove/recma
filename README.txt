= RKelly

  http://rkelly.rubyforge.org/

== DESCRIPTION

The RKelly library will parse JavaScript and return a parse tree suitable
for feeding to Ruby2Ruby.

== Example

  require 'rkelly'
  require 'ruby2ruby'

  parser = RKelly.new
  tree   = parser.process(
    "for(var i = 0; i < 10; i++) { var x = 5 + 5; }"
  )
  puts RubyToRuby.new().process(tree)

== Authors

Copyright (c) 2007 by Aaron Patterson (aaronp@rubyforge.org) 

== Acknowledgments

The javascript parser was was taken from rbnarcissus written by Paul Sowden.
Thanks Paul!

  http://idontsmoke.co.uk/2005/rbnarcissus/
  
== License

This library is distributed under the GPL.  Please see the LICENSE[link://files/LICENSE_txt.html] file.

