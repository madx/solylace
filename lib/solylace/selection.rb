module Solylace

  class Selection
    attr_reader :start, :end

    def initialize(buffer)
      @buffer = buffer
      reset!
    end

    def reset!
      @start = @end = @buffer.cursor
    end

    def update(heading, motion)
      @start = @buffer.cursor unless selecting?
      @buffer.move heading, motion, true
      @end = @buffer.cursor
      restrict!
    end

    def selecting?
      @start != @end
    end

    def inspect
      if selecting?
        "%s-%s" % [@start, @end]
      else
        "nil"
      end
    end

    def normalize
      if @start <= @end then [@start, @end] else [@end, @start] end
    end

    private

    def restrict!
      if @start < 0          then @start = 0            end
      if @end > @buffer.size then @end   = @buffer.size end
    end

  end

end
