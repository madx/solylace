module Solylace

  class Buffer

    attr_reader   :state, :separator
    attr_accessor :cursor

    def initialize(string)
      @text      = string
      @state     = :idle
      @separator = " .,:;{}[]()/?!#\n".split(//)
      @cursor    = 0
    end

    def to_s
      @text
    end

    def column
      if @cursor - 1 <= 0
        1
      else
        @cursor - (@text.rindex("\n", @cursor - 1) || -1) 
      end
    end

    def line
      @text[0..@cursor].count("\n") + 1
    end
    
  end

end
