module Solylace

  class Buffer
    
    attr_reader   :cursor, :state
    attr_accessor :sep, :text

    def initialize(string="")
      @text   = string
      @cursor = 0
      @edit   = ""
      @select = Selection.new(self)
      @sep    = " .,:;{}[]()/?!#\n".split(//)
      @state  = :idle
      @sdata  = nil
    end

    # Action 

    def move(heading, motion=:char, nested=false)
      case heading

        when :left, :right
          enter :hmove unless nested
          horizontal_move heading, motion

        when :up, :down
          enter :vmove, column unless nested
          if in_state?(:select) && @sdata.nil? then @sdata = column end
          vertical_move heading, motion

        else raise ArgumentError, "no such heading: #{heading}"
      end
    end

    def select(heading, motion=:char)
      enter :select
      @select.update(heading, motion)
    end

    def delete(heading, motion=:char)
      enter :idle if in_state? :edit
      if @select.selecting?
        cur = @select.normalize
        @cursor = cur[0]
        @text.slice!(cur[0]...cur[1])
      else
        select heading, motion
        delete nil, nil
      end
      enter :idle
    end

    def input(string)
      if @select.selecting?
        delete nil, nil
        input string
      else
        enter :edit
        @edit << string
      end
    end
    alias :<< :input

    def inspect
      "(Buffer " + 
      %w(@state @cursor @sdata @select @edit).collect! { |x| 
        "#{x}=#{instance_variable_get(x).inspect}" 
      }.join(' ') + ")"
    end

    def set(option, value=true)
    end

    # Queries

    def to_a
      case @state
        when :select
          lim = @select.normalize
          Array[
            @text[0...lim[0]], 
            @text[lim[0]...lim[1]],
            @text[lim[1]..@text.length]
          ]
        when :edit
          Array[
            @text[0...@cursor],
            @edit,
            @text[@cursor..@text.length]
          ]
          
        else
          [@text]
      end
    end

    def cursor
      if in_state? :edit
        @cursor + @edit.length
      else
        @cursor
      end
    end

    def in_state?(state)
      @state.eql? state
    end

    def lines
      if in_state? :edit
        to_a.inject(0) {|sum,s| sum += s.count("\n") } + 1
      else
        @text.count("\n") + 1
      end
    end

    def line
      if in_state? :edit
        (@text[0...@cursor] + @edit).count("\n") + 1
      else
        @text[0...@cursor].count("\n") + 1
      end
    end

    def column
      offset = @cursor - 1 < 0 ? 0 : @cursor - 1
      if in_state? :edit
        cursor - (@text.rindex("\n", offset) || - 1 ) 
      else
        @cursor - (@text.rindex("\n", offset) || - 1 ) 
      end
    end

    def size
      @text.length
    end

    private 

    def enter(state, data=nil)
      if @state != state
        @sdata = data
        @state = state
      end
      @select.reset! unless in_state? :select
      merge! unless in_state? :edit
      @edit = "" unless in_state? :edit
    end

    def horizontal_move(heading, motion)
      if heading.eql? :left
        return if on? :start 
        case motion

          when :char
            @cursor -= 1 

          when :word
            if on? :after_sep
              sep = char(@cursor - 1)
              @cursor -= 1 while !on?(:start) && char(@cursor - 1).eql?(sep)
            else
              @cursor -= 1 while !on?(:start) && !on?(:after_sep)
            end

          when :line
            @cursor -= 1 until on?(:start) || on?(:line_start)
        end

      else
        return if on? :end
        case motion
          when :char
            @cursor += 1

          when :word
            if on? :separator
              sep = char
              @cursor += 1 while !on?(:end) && char.eql?(sep)
            else
              @cursor += 1 while !on?(:end) && !on?(:separator)
            end

          when :line
            @cursor += 1 until on?(:end) || on?(:line_end)
        end

      end
    end # horizontal_move

    def vertical_move(heading, motion)
      if heading.eql? :up
        return if on?(:start) || on?(:first_line)
        case motion
          when :char, :word
            @cursor = @text.rindex("\n", @cursor - 1)
            horizontal_move :left, :line
            (@sdata - 1).times do
              break if on? :line_end
              @cursor += 1
            end

          when :line
            @sdata = 1
            vertical_move :up, :char

        end

      else
        return if on? :last_line
        case motion
          when :char, :word
            @cursor = @text.index("\n", @cursor) + 1
            if @sdata.eql? :line_end
              horizontal_move :right, :line
            else
              (@sdata - 1).times do
                break if on? :line_end
                @cursor += 1
              end
            end

          when :line
            @sdata = :line_end
            vertical_move :down, :char

        end

      end
    end # vertical_move

    def on?(query)
      {
        :start      => proc { @cursor.zero?                        },
        :end        => proc { @cursor.eql? @text.length            },
        :first_line => proc { @text.rindex("\n", @cursor - 1).nil? },
        :last_line  => proc { @text.index("\n", @cursor).nil?      },
        :line_start => proc { char(@cursor - 1).eql? "\n"          },
        :line_end   => proc { char.eql? "\n"                       },
        :separator  => proc { @sep.member? char                    },
        :after_sep  => proc { @sep.member? char(@cursor - 1)       }
      }[query].call
    end

    def char(position=nil)
      position ||= @cursor
      if position < 0 || position >= @text.length
        nil
      else
        @text[position].chr
      end
    end

    def merge!
      @text   = @text[0...@cursor] << @edit << @text[@cursor..@text.length]
      @cursor = @cursor + @edit.length
    end

  end

end
