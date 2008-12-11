libpath = File.join(File.dirname(__FILE__), 'lib')
$:.unshift(libpath) unless $:.member? libpath
require 'buffer'

Shoes.app :height => 500, :width => 600 do
  @buf = Solylace::Buffer.new

  background gray(0.9)

  flow do
    background "#444".."#111"
    subtitle "Solylace", :stroke => white, :font => "20px", :margin => [5,7,15,5]
    @open = button("Open", :margin => 5) do
      file = ask_open_file
      if File.readable?(file)
        @buf = Solylace::Buffer.new(File.read(file))
        @text.replace @buf.text
      else
        alert "%s is not readable" % File.basename(file)
      end
    end
  end

  stack do
    background "#222"
    @status = para "Lines: 0", :margin => 5, :stroke => gray(0.8)
  end

  @text = para @buf.text, :font => "DejaVu Sans Mono 12px"
  @text.cursor = 0

  keypress do |k|
    case k
      when String
        @buf << k
      when :left, :right
        @buf.move :char, k
      when :backspace
        @buf.delete :char, :left
      when :delete
        @buf.delete :char, :right
      when :shift_left
        @buf.expand_selection :char, :left
      when :shift_right
        @buf.expand_selection :char, :right
    end

    @text.cursor = @buf.cursor

    contents = if @buf.selecting?
      [@buf.before, strong(@buf.selection, :fill => "#999"), @buf.after]
    else @buf.text end

    @text.replace contents
    @status.replace "Lines: %s | Cursor: %s | Select: %s" % 
      [@buf.lines, @buf.cursor, @buf.select.inspect]
  end

end
