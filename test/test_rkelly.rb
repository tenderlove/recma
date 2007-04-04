$LOAD_PATH.unshift File.join('..', 'lib')

require 'test/unit'
require 'rkelly'

class TestRKelly < Test::Unit::TestCase
  def setup
    @processor = RKelly.new
  end

  @@testcases = {
    "defn_empty" => {
      "JS"          => "function empty() {\n}",
      "ParseTree"   => [:block, [:defn, "empty", [:scope, [:block, [:args], [:block]]]]]
    },

    "defn_add" => {
      "JS"          => "function empty() {\n return 1 + 5;\n}",
      "ParseTree"   => [:block, [:defn,
                          "empty",
                          [:scope,
                            [:block,
                              [:args],
                              [:block,
                              [:return,
                                 [:call, [:lit, 1], :+, [:lit, 5]]]
                              ]
                            ]
                          ]
                        ]]
    },
    "var_assign" => {
      "JS"          => "var x = 1 + 5;",
      "ParseTree"   => [:block, [:lasgn, :x, [:call, [:lit, 1], :+, [:lit, 5]]]]
    },

    "less_than" => {
      "JS" => 'x < y',
      "ParseTree"   => [:block, [:call, [:lvar, :x], :<, [:array, [:lvar, :y]]]]
    },

    "less_than_equal" => {
      "JS" => 'x <= y',
      "ParseTree"   => [:block, [:call, [:lvar, :x], :<=, [:array, [:lvar, :y]]]]
    },

    "greater_than" => {
      "JS" => 'x > y',
      "ParseTree"   => [:block, [:call, [:lvar, :x], :>, [:array, [:lvar, :y]]]]
    },

    "greater_than_equal" => {
      "JS" => 'x >= y',
      "ParseTree"   => [:block, [:call, [:lvar, :x], :>=, [:array, [:lvar, :y]]]]
    },

    "pre_increment" => {
      "JS"          => "++i;",
      "ParseTree"   => [:block, [:lasgn, :i, [:call, [:lvar, :i], :+, [:array, [:lit, 1]]]]]
    },

    "post_increment" => {
      "JS"          => "i++;",
      "ParseTree"   => [:block, [:call, [:array, [:lvar, :i], [:lasgn, :i, [:call, [:lvar, :i], :+, [:array, [:lit, 1]]]]], :first]]
    },

    "post_decrement" => {
      "JS"          => "i--;",
      "ParseTree"   => [:block, [:call, [:array, [:lvar, :i], [:lasgn, :i, [:call, [:lvar, :i], :-, [:array, [:lit, 1]]]]], :first]]
    },

    "pre_decrement" => {
      "JS"          => "--i;",
      "ParseTree"   => [:block, [:lasgn, :i, [:call, [:lvar, :i], :-, [:array, [:lit, 1]]]]]
    },

    "for_loop" => {
      "JS"          => "for(var i = 0; i < 10; i++) {\nvar x = 5 + 5;\n}",
      "ParseTree"   => [:block, [:begin,
        [:block,
           [:lasgn, :i, [:lit, 0]],
           [:while,
            [:call, [:lvar, :i], :<, [:array, [:lit, 10]]],
            [:block,
              [:lasgn, :x, [:call, [:lit, 5], :+, [:lit, 5]]],
              [:call,
                [:array, [:lvar, :i], [:lasgn, :i, [:call, [:lvar, :i], :+, [:array, [:lit, 1]]]]], :first]],
            true]
        ]
      ]]
    },

    "if_statement" => {
      "JS"          => "if(1 == 1) {\n}",
      "ParseTree"   => [:block, [:if, [:call, [:lit, 1], :==, [:array, [:lit, 1]]], [:block]]]
    },

    "call" => {
      "JS"          => "alert('hello');",
      "ParseTree"   => [:block, [:fcall, :alert, [:array, [:str, "hello"]]]]
    },

    "plus_equal" => {
      "JS"          => "var s = 0;\ns += 1;",
      "ParseTree"   => [:block,
         [:lasgn, :s, [:lit, 0]],
          [:lasgn, :s, [:call, [:lvar, :s], :+, [:array, [:lit, 1]]]]]
    },

    "minus_equal" => {
      "JS"          => "var s = 0;\ns -= 1;",
      "ParseTree"   => [:block,
         [:lasgn, :s, [:lit, 0]],
          [:lasgn, :s, [:call, [:lvar, :s], :-, [:array, [:lit, 1]]]]]
    },

    "constant" => {
      "JS"          => "var s = Date;",
      "ParseTree"   => [:block, [:lasgn, :s, [:const, :Date]]]
    },

    "init_date" => {
      "JS"          => "var s = new Date();",
      "ParseTree"   => [:block, [:lasgn, :s, [:call, [:const, :Date], :new]]]
    },

    "init_object" => {
      "JS"          => "var s = new Object();",
      "ParseTree"   => [:block,
        [:lasgn, :s, [:call, [:const, :OpenStruct], :new]]]
    },

    "call_method" => {
      "JS"          => "var s = new Date();\ns.getSeconds();",
      "ParseTree"   => [:block,
        [:lasgn, :s, [:call, [:const, :Date], :new]],
        [:call, [:lvar, :s], :getSeconds, [:array]]
      ]
    },

    "method_chain" => {
      "JS"          => "var s = document.forms[0].elements[0];",
      "ParseTree"   => [:block,
        [:lasgn, :s,
          [:call,
            [:call,
              [:call,
                [:call, [:lvar, :document], :forms],
              :[], [:array, [:lit, 0]]],
            :elements],
          :[],
         [:array, [:lit, 0]]]]]
    },

    "array_index_set" => {
      "JS"          => "var s = new Array();\ns[0] = 10;",
      "ParseTree"   => [:block,
        [:lasgn, :s, [:call, [:const, :Array], :new]],
        [:attrasgn, [:lvar, :s], :[]=, [:array, [:lit, 0], [:lit, 10]]]
      ]
    },

    "array_index_get" => {
      "JS"          => "var s = new Array();\ns[0] = 10;\nvar k = s[0];",
      "ParseTree"   => [:block,
        [:lasgn, :s, [:call, [:const, :Array], :new]],
        [:attrasgn, [:lvar, :s], :[]=, [:array, [:lit, 0], [:lit, 10]]],
        [:lasgn, :k, [:call, [:lvar, :s], :[], [:array, [:lit, 0]]]]
      ]
    },

    "assign_no_var" => {
      "JS"          => "s = 'asdfasdf';",
      "ParseTree"   => [:block, [:lasgn, :s, [:str, "asdfasdf"]]]
    },

    "assign_many_calls" => {
      "JS"          => "document.form[0].name = \"asdfadsfadsf\";",
      "ParseTree"   => [:block,
        [:attrasgn,
          [:call, [:call, [:lvar, :document], :form], :[], [:array, [:lit, 0]]],
          :name=,
          [:array, [:str, "asdfadsfadsf"]]
        ]
    ]
    },
    "simple_object" => {
      "JS" => "function foo() { alert('foo'); } function bar() { this.r = foo; }",
      "ParseTree" => [:block,
                      [:defn, "foo",
                        [:scope, [:block, [:args],
                          [:block,
                            [:fcall, :alert, [:array, [:str, "foo"]]]]
                          ]
                        ]
                      ],
                    [:defn, "bar",
                      [:scope, [:block, [:args],
                        [:block,
                          [:sclass, [:vcall, :self],
                            [:defn, "r", [:scope,
                              [:block, [:args],
                                [:block,
                                  [:fcall, :alert, [:array, [:str, "foo"]]]
                                ]
                              ]
                            ]]
                          ]
                        ]
                      ]]
                     ]
    ]
    },
    "custom_object" => {
      "JS" => "function foo() { this.bar = 'aaron'; } baz = new foo();",
      "ParseTree" => [:block,
        [:class, :Foo, [:const, :OpenStruct],
          [:defn, "initialize",
            [:scope, [:block, [:args], [:super], [:fcall, :foo]]]
          ],
          [:defn, "foo",
            [:scope, [:block, [:args],
              [:block,
                [:attrasgn, [:self], :bar=, [:array, [:str, "aaron"]]]
              ]]]]],
          [:defn, "foo",
            [:scope, [:block, [:args],
              [:block,
                [:attrasgn, [:self], :bar=, [:array, [:str, "aaron"]]]
              ]]]],
        [:lasgn, :baz, [:call, [:lvar, :Foo], :new]]]
    },
    "dynamic_method_assignment" => {
      "JS" => " var g = new Object();
                g.test = function () { alert('asd'); }
                g.test();",
      "ParseTree" => [:block,
                      [:lasgn, :g, [:call, [:const, :OpenStruct], :new]],
                      [:sclass, [:lvar, :g], [:scope,
                        [:defn, :test, [:scope, [:block, [:args], [:block,
                          [:fcall, :alert, [:array, [:str, "asd"]]]
                        ]]]]
                      ]],
                      [:call, [:lvar, :g], :test, [:array]]
                    ]
    },
    "dynamic_method_assignment_with_var" => {
      "JS" => " var g = new Object();
                g.test = function (boo) { alert(boo); }
                g.test('aaron');",
      "ParseTree" => [:block,
                      [:lasgn, :g, [:call, [:const, :OpenStruct], :new]],
                      [:sclass, [:lvar, :g], [:scope,
                        [:defn, :test, [:scope, [:block, [:args, :boo], [:block,
                          [:fcall, :alert, [:array, [:lvar, :boo]]]
                        ]]]]
                      ]],
                      [:call, [:lvar, :g], :test, [:array, [:str, 'aaron']]]
                    ]
    },
  }

  @@testcases.each do |node, data|
    define_method :"test_#{node}" do
      pt = data['ParseTree']
      js = data['JS']

      result = @processor.process(js)

      assert_not_nil pt, "ParseTree for #{node} undefined"
      assert_not_nil js, "JavaScript for #{node} undefined" 
      assert_equal pt, result
    end
  end
end
