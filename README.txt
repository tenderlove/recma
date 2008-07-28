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

The original javascript parser was was taken from rbnarcissus written by
Paul Sowden.  Thanks Paul!

  http://idontsmoke.co.uk/2005/rbnarcissus/

The current parser was ported from WebKit.  Thank you WebKit team!
  
== License

The MIT License

Copyright (c) 2007, 2008 Aaron Patterson, John Barnette

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE
