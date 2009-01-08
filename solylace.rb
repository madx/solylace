libpath = File.join(File.dirname(__FILE__), 'lib')
$:.unshift(libpath) unless $:.member? libpath
%w(selection buffer).each {|dep| require dep }

Shoes.app :height => 500, :width => 700 do
  LINE_HEIGHT = 460/24 # This is true for DejaVu Sans Mono 12px,
                       # maybe only on my system though
  @buf = Solylace::Buffer.new

  background gray(0.9)

  flow :height => 40 do
    background "#444".."#111"
    subtitle "Solylace", :stroke => white, :font => "20px", :margin => [5,7,15,5]
  end
  
  stack :width => 100, :height => 460 do
    background "#222"
    @open = para link("Open", :click => proc {
      @buf = Solylace::Buffer.new(File.read(ask_open_file)) 
      @text.replace @buf.text
    }), :stroke => "#eee"
  end

  @edit_zone = stack :width => -100, :height => 460, :scroll => true do
    @text = para @buf.text, :font => "DejaVu Sans Mono 12px"
  end
  @edit_zone.scroll_top = 0

  @text.cursor = 0

  keypress do |k|
    case k
      when :left, :right, :up, :down
        @buf.move k, :char

      when :end  then @buf.move :right, :line
      when :home then @buf.move :left,  :line

      when :control_left  then @buf.move :left,  :word
      when :control_right then @buf.move :right, :word
      when :control_up    then @buf.move :up,    :line
      when :control_down  then @buf.move :down,  :line

      when :shift_right   then @buf.select :right, :char 
      when :shift_left    then @buf.select :left,  :char 
      when :shift_up      then @buf.select :up,    :char 
      when :shift_down    then @buf.select :down,  :char 

      when :control_shift_left  then @buf.select :left,  :word
      when :control_shift_right then @buf.select :right, :word

      when :shift_end  then @buf.select :right, :line
      when :shift_home then @buf.select :left,  :line

      when :backspace then @buf.delete :left,  :char
      when :delete    then @buf.delete :right, :char

      when String then @buf << k
      when :tab   then @buf << "  "

      when :alt_q then quit
    end

    @text.cursor = @buf.cursor

    case @buf.state
      when :select
        @text.replace @buf.to_a[0], 
          span(@buf.to_a[1], :fill => '#aaa'), 
          @buf.to_a[2]
      when :edit
        @text.replace @buf.to_a
      else
        @text.replace @buf.to_a[0]
    end

    update_viewport! if @buf.in_state?(:vmove)

  end # keypress

  def update_viewport!
    y = @buf.line * LINE_HEIGHT
    if y > @edit_zone.scroll_top + @edit_zone.height
      scroll :up
    elsif y <= @edit_zone.scroll_top
      scroll :down
    end
  end

  def scroll(heading)
    case heading
      when :up   then @edit_zone.scroll_top += LINE_HEIGHT
      when :down then @edit_zone.scroll_top -= LINE_HEIGHT
      else error("unknown heading #{heading} for scroll")
    end
  end

end
