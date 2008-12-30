module RKelly
  module Visitors
    class RealSexpVisitor < Visitor
      ALL_NODES.each do |type|
        eval <<-RUBY
          def visit_#{type}Node(o)
            s(:#{type.scan(/[A-Z][a-z]+/).join('_').downcase}, *super)
          end
        RUBY
      end
    end
  end
end
