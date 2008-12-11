module Solylace

  class Selection
    attr_reader :start, :end, :heading

    def initialize
      reset 0
    end

    def reset(cursor)
      @start = @end = cursor
      @heading = :right
    end

    def expand(heading)
      if selecting?
        expand_selection heading
      else
        start_selection heading
      end
    end

    def restrict(size)
      if @start < 0  then @start = 0    end
      if @end > size then @end   = size end
    end

    def set(start, _end)
      @start, @end = start, _end
    end

    def selecting?
      @start != @end
    end

    def length
      @end - @start
    end

    def inspect
      if selecting?
        "%s%s%s" % [@start, @heading.eql?(:left) ? '<-' : '->', @end]
      else
        "nil"
      end
    end

    private

    def expand_selection(heading)
      if @heading.eql? :left
        @start += heading.eql?(:right) ? 1 : -1
      else
        @end   += heading.eql?(:right) ? 1 : -1
      end
    end

    def start_selection(heading)
      @heading = :right
      if heading.eql? :left
        @start  -= 1
        @heading = :left
      else
        @end += 1
      end
    end

  end

end
