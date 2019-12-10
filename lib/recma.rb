require 'recma/constants'
require 'recma/visitable'
require 'recma/visitors'
require 'recma/parser'
require 'recma/runtime'
require 'recma/syntax_error'

module RECMA
  class << self
    def parse *args
      RECMA::Parser.new.parse(*args)
    end
  end
end
