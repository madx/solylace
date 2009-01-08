libpath = File.join(File.dirname(__FILE__), 'lib')
$:.unshift(libpath) unless $:.member? libpath
%w(selection buffer command).each {|dep| require dep }

Shoes.app :height => 520, :width => 600, :resizable => false do
  def attr_accessor(*syms)
    syms.each do |attribute|
      meths = %Q{
        def #{attribute}()
          @#{attribute}
        end
        def #{attribute}=(o)
          @#{attribute} = o
        end
      }
      instance_eval meths
    end
  end
  attr_accessor :buf, :buffers, :status, :text

  LINE_HEIGHT = 460/24 # This is true for DejaVu Sans Mono 12px,
                       # maybe only on my system though
  @command = Solylace::Command.new(self)
  @buf = Solylace::Buffer.new
  @buffers = {nil => @buf}

  background gray(0.9)

  flow :height => 40 do
    background "#444".."#111"
    subtitle "Solylace", :stroke => white, :font => "20px", :margin => [5,7,15,5]
  end

  @edit_zone = stack :width => 1.0, :height => 460, :scroll => true do
    @text = para @buf.text, :font => "DejaVu Sans Mono 12px"
  end
  @edit_zone.scroll_top = 0
  @text.cursor = 0

  @statusbar = flow :width => 1.0, :height => 20 do
    background "#222"
    @status = para "", :font => "DejaVu Sans 10px", 
                       :stroke => "#bfbfbf", :margin => 4
  end
  @status.replace "Welcome to Solylace, press F1 for help."

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
      when :alt_o then @command.open
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
      scroll :down
    elsif y <= @edit_zone.scroll_top || y == LINE_HEIGHT
      scroll :up
    end
  end

  def scroll(heading)
    case heading
      when :up   then @edit_zone.scroll_top -= LINE_HEIGHT
      when :down then @edit_zone.scroll_top += LINE_HEIGHT
      else error("unknown heading #{heading} for scroll")
    end
  end

end
