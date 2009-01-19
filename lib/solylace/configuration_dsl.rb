module Solylace
  class ConfigurationDSL
    
    # Creates a blank DSL. The optional Hash sets default values.
    def initialize(hash={})
      @hash = hash
    end

    def set(opt, value=true)
      @hash[opt] = value
    end

    def path(item, value)
      @hash[:paths][item] = value
    end

    def theme(name, &blk)
      @hash[:theme] = name
    end

    # Return the internal hash.
    def __hash()
      @hash
    end

  end
end
