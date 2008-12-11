module Solylace
  class Buffer
    attr_reader :text, :cursor, :select

    def initialize(string="")
      @text   = string
      @cursor = 0
      @select = [0, 0, :right]
    end

    # Insert a string at the current cursor position or replace the selection
    # with a string.
    def insert(str)
      @text = @text[0...@cursor] + str + @text[@cursor..@text.length]
      @cursor += str.length
      reset_selection!
    end
    alias :<< :insert

    # Delete characters from the current position by specifying a motion 
    # and a heading. If the selection area is not empty, this method only 
    # removes the selected text.
    def delete(motion, heading)
      if selecting?
        @text.slice!(@select[0], @select[1]-@select[0])
        @cursor = @select[0]
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
      reset_selection!
    end

    # Moves the cursor right or left in the string, breaking the selection.
    def move(motion, heading)
      reset_selection!
      move_cursor motion, heading
      reset_selection!
    end

    # Expands the selection left or right.
    def expand_selection(motion, heading)
      if selecting?
        if @select[2].eql? :left
          if heading.eql? :right
            @select[0] += 1
          else
            @select[0] -= 1
          end
        else
          if heading.eql? :right
            @select[1] += 1
          else
            @select[1] -= 1
          end
        end
      else
        @select[2] = :right
        case heading
          when :left
            @select[0] -= 1
            @select[2] = :left
          when :right
            @select[1] += 1
        end
      end
      if @select[0] < 0            then @select[0] = 0            end
      if @select[1] > @text.length then @select[1] = @text.length end
      move_cursor motion, heading
    end

    # Return the number of lines of the text.
    def lines
      @text.count("\n") + 1
    end
    
    # Return characters before the cursor. 
    def before
      @text[0...@select[0]]
    end

    # Return characters after the cursor.
    def after
      @text[@select[1]..@text.length]
    end

    # Returns the characters currently selected.
    def selection
      @text[@select[0]...@select[1]]
    end

    # Determines if something is actually selected.
    def selecting?
      @select[0] != @select[1]
    end

    private

    def move_cursor(motion, heading)
      case heading
        when :left
          @cursor -= 1 unless @cursor.zero?
        when :right
          @cursor += 1 unless @cursor.eql? @text.length
      end
    end

    def reset_selection!
      @select = [@cursor, @cursor, :right]
    end

  end
end
