module Solylace
  class Buffer
    attr_reader :text, :cursor, :select

    def initialize(string="")
      @text   = string
      @cursor = 0
      @select = Selection.new
    end

    # Insert a string at the current cursor position or replace the selection
    # with a string.
    def insert(str)
      if @select.selecting?
        delete nil, nil
        insert str
      else
        @text = @text[0...@cursor] + str + @text[@cursor..@text.length]
        @cursor += str.length
        @select.reset @cursor
      end
    end
    alias :<< :insert

    # Delete characters from the current position by specifying a motion 
    # and a heading. If the selection area is not empty, this method only 
    # removes the selected text.
    def delete(motion, heading)
      if @select.selecting?
        @text.slice!(@select.start, @select.length)
        @cursor = @select.start
      else
        case motion
          when :char
            case heading
              when :right
                @text.slice!(@cursor, 1)
              when :left
                @text.slice!(@cursor - 1, 1)
                move_cursor :char, :left
            end
        end
      end
      @select.reset @cursor
    end

    # Moves the cursor right or left in the string, breaking the selection.
    def move(motion, heading)
      @select.reset @cursor
      move_cursor motion, heading
      @select.reset @cursor
    end

    # Expands the selection left or right.
    def expand_selection(motion, heading)
      case motion
        when :char
          @select.expand(heading)
      end
      @select.restrict(@text.length)
      move_cursor motion, heading
    end

    # Return the number of lines of the text.
    def lines
      @text.count("\n") + 1
    end
    
    # Return characters before the cursor. 
    def before
      @text[0...(@select.start)]
    end

    # Return characters after the cursor.
    def after
      @text[(@select.end)..(@text.length)]
    end

    # Returns the characters currently selected.
    def selection
      @text[(@select.start)...(@select.end)]
    end

    private

    def move_cursor(motion, heading)
      case motion

        when :char
          case heading
            when :left
              @cursor -= 1 unless @cursor.zero?
            when :right
              @cursor += 1 unless @cursor.eql? @text.length
          end

        when :line
          case heading
            when :right
              @cursor += 1 until @text[@cursor].nil? || @text[@cursor].eql?(10)
            when :left
              @cursor -= 1 while @cursor > 0 && @text[@cursor-1] != 10
          end
      end
    end

  end
end
