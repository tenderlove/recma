module RKelly
  module JS
    # Class to represent Not A Number
    # In Ruby NaN != NaN, but in JS, NaN == NaN
    class NaN < ::Numeric
      def ==(other)
        other.is_a?(::Numeric) && other.nan?
      end

      def nan?
        true
      end
    end
  end
end
