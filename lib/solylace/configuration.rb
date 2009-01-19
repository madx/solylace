module Solylace
  class Configuration < Metash

    DEFAULTS = {
      :auto_indent  => true,
      :line_numbers => true,
      :tab_width    => 2,
      :font         => "DejaVu Sans Mono 10px",

      :paths => {
        :shoes  => "/usr/bin/shoes",
        :tools  => "/usr/lib/solylace/tools/",
        :fonts  => "",
        :themes => ""
      },
      :theme => :default,
    }

    # Build up a default configuration
    def self.defaults
      new(DEFAULTS.dup)
    end

    # Build a configuration from a given block of code. The block is evaluated
    # in the context of a ConfigurationDSL created with the defaults
    def self.build(&blk)
      dsl = ConfigurationDSL.new(DEFAULTS.dup)
      dsl.instance_eval(&blk)
      Configuration.new(dsl.__hash)
    end

  end
end
