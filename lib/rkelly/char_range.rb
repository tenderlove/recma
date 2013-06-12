require 'rkelly/char_pos'

module RKelly
  # Represents a syntax element location in source code - where it
  # begins and where it ends.
  #
  # It's a value object - it can't be modified.
  class CharRange
    attr_reader :from, :to

    def initialize(from, to)
      @from = from
      @to = to
    end

    # Creates a new range that immediately follows this one and
    # contains the given string.
    def next(string)
      CharRange.new(@to.next(string.slice(0, 1)), @to.next(string))
    end

    def to_s
      "<#{@from} .. #{@to}>"
    end

    # A re-usable empty range
    EMPTY = CharRange.new(CharPos::EMPTY, CharPos::EMPTY)
  end
end
