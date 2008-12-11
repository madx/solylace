libpath = File.join(File.dirname(__FILE__), 'lib')
$:.unshift(libpath) unless $:.member? libpath
%w(selection buffer).each {|dep| require dep }

Shoes.app :height => 500, :width => 600 do
  @buf = Solylace::Buffer.new

  background gray(0.9)

  flow do
    background "#444".."#111"
    subtitle "Solylace", :stroke => white, :font => "20px", :margin => [5,7,15,5]
    #@open = button("Open", :margin => 5) do
    #  file = ask_open_file
    #  if File.readable?(file)
    #    @buf = Solylace::Buffer.new(File.read(file))
    #    @text.replace @buf.text
    #  else
    #    alert "%s is not readable" % File.basename(file)
    #  end
    #end
  end

  stack do
    background "#222"
    @status = para "", :margin => 5, :stroke => gray(0.8), :font => "12px"
  end

  @text = para @buf.text, :font => "DejaVu Sans Mono 12px"
  @text.cursor = 0

  keypress do |k|
    case k
      when String
        @buf << k
      when :tab
        @buf << "  "
      when :left, :right
        @buf.move :char, k
      when :end
        @buf.move :line, :right
      when :home
        @buf.move :line, :left
      when :backspace
        @buf.delete :char, :left
      when :delete
        @buf.delete :char, :right
      when :shift_left
        @buf.expand_selection :char, :left
      when :shift_right
        @buf.expand_selection :char, :right
      when :control_c
        self.clipboard = @buf.selection
      when :control_v
        @buf << self.clipboard
      when :control_x
        if @buf.selecting? then self.clipboard = @buf.delete(nil, nil) end
      when :alt_q
        quit
    end

    @text.cursor = @buf.cursor

    contents = if @buf.selecting?
      [@buf.before, span(@buf.selection, :fill => "#aaa"), @buf.after]
    else @buf.text end

    @text.replace contents
    @status.replace "Lines: %s | " % @buf.lines, "Pos: %s | " % @buf.cursor,
      "Selection: ", code(@buf.select.inspect), 
      code(" [%s] " % @buf.selection),
      "| Clipboard: %s" % self.clipboard.inspect
  end

end
