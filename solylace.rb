libpath = File.join(File.dirname(__FILE__), 'lib')
$:.unshift(libpath) unless $:.member? libpath
%w(selection buffer command binder).each {|dep| require dep }

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
  @binder = Solylace::Binder.new
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

  # Keybinds
  [:left, :right, :up, :down].each do |k|
    @binder.bind(k)            { @buf.move k, :char }
    @binder.bind("shift_#{k}") { @buf.select k, :char  }
  end
  [:left, :right].each do |k|
    @binder.bind("control_#{k}")       { @buf.move   k, :word }
    @binder.bind("control_shift_#{k}") { @buf.select k, :word }
  end
  @binder.bind(:control_up)   { @buf.move   :up,    :line }
  @binder.bind(:control_down) { @buf.move   :down,  :line }
  @binder.bind(:end)          { @buf.move   :right, :line }
  @binder.bind(:home)         { @buf.move   :left,  :line }
  @binder.bind(:shift_end)    { @buf.select :right, :line }
  @binder.bind(:shift_home)   { @buf.select :left,  :line }
  @binder.bind(:backspace)    { @buf.delete :left,  :char }
  @binder.bind(:delete)       { @buf.delete :right, :char }
  @binder.bind(:enter)        { @buf << "\n"  }
  @binder.bind(:tab)          { @buf << "  "  }
  @binder.bind(String)        { |k| @buf << k }
  @binder.bind(:alt_q)        { quit }

  keypress do |k| 
    @binder.handle(k, self)
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

    update_viewport!
    update_status!
  end

  def update_viewport!
    y = @buf.line * LINE_HEIGHT
    if y > @edit_zone.scroll_top + @edit_zone.height
      scroll :down
    elsif y <= @edit_zone.scroll_top || y == LINE_HEIGHT
      scroll :up
    end
  end

  def update_status!
    @status.replace "#{@buf.line},#{@buf.column}"
  end

  def scroll(heading)
    case heading
      when :up   then @edit_zone.scroll_top -= LINE_HEIGHT
      when :down then @edit_zone.scroll_top += LINE_HEIGHT
      else error("unknown heading #{heading} for scroll")
    end
  end

end
