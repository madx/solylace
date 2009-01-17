module Solylace
  class Command
    
    def initialize(shoes_app)
      @app = shoes_app
    end

    def open
      file = @app.ask_open_file
      if @app.buffers.keys.member? file
        @app.error "File already opened"
      else
        @app.buffers[file] = Buffer.new(File.read(file))
        @app.buf = @app.buffers[file]
      end
    end

  end
end
