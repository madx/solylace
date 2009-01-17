module Solylace

  class Binder

    def initialize
      @binds = {}
    end

    def handle(key, context)
      if @binds.key?(key)
        @binds[key].call
      elsif key.is_a?(String)
        @binds[String].call(key)
      end
    end

    def bind(key, &blk)
      if key.is_a?(Class)
        @binds[key] = blk
      else
        @binds[key.to_sym] = blk
      end
    end

  end
  
end
