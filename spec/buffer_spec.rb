require File.join( File.dirname(__FILE__), '..', 'lib', 'solylace' )
include Solylace

describe Buffer do
  
  before(:each) do
    @buffer = Buffer.new "This is a sample buffer"
  end

  it "should have a default state" do
    @buffer.state.should eql(:idle)
  end

  it "should have a default separator" do
    @buffer.separator.should eql(" .,:;{}[]()/?!#\n".split(//))
  end
  
  it "should set the cursor to 0 when created" do
    @buffer.cursor.should eql(0)
  end

  #= to_s()
  describe "#to_s" do
    it "should convert the buffer to a string" do
      @buffer.to_s.should eql("This is a sample buffer")
    end
  end

  #= column()
  describe "#column" do
    before(:each) do
      @buffer = Buffer.new "This is a\nmultiline\n sample buffer"
    end

    # This is a
    # multiline
    # sample buffer

    it "should return the current column" do
      @buffer.column.should eql(1)
    end

    it "should return the right column on the first line jump" do
      @buffer.cursor = 9
      @buffer.column.should eql(10)
    end

    it "should return the right column on any line jump" do
      @buffer.cursor = 19
      @buffer.column.should eql(10)
    end

    it "should return the distance to the line start" do
      @buffer.cursor = 13
      @buffer.column.should eql(4)
    end

  end

  #= line()
  describe "#line" do
    before(:each) do
      @buffer = Buffer.new "This is a\n multiline sample buffer"
    end

    it "should return 1 if on the first line" do
      @buffer.line.should eql(1)
    end

    it "should return the line number otherway" do
      @buffer.cursor = 20
      @buffer.line.should eql(2)
    end

  end

  #= move(heading, motion)
  describe "#move" do

    #= move(heading, :char)
    describe "by character" do

      it "should change the state to :hmove when heading is left or right" do
        @buffer.move :right, :char
        @buffer.state.should eql(:hmove)
      end

      it "should change the state to :vmove when heading is up or down" do
        @buffer.move :up, :down
        @buffer.state.should eql(:vmove)
      end

      it "should store the column where the vertical move started" do
        orig = @buffer.column
        @buffer.move :up, :down
        @buffer.__data.should eql(orig)
      end

      it "should allow to move character by character" do
        @buffer.move :right, :char
        @buffer.cursor.should eql(1)
      end

      it "should never make the cursor less than 0" do
        10.times { @buffer.move :left, :char }
        @buffer.cursor.should eql(0)
      end

      it "should never make the cursor greater than the text size" do
        30.times { @buffer.move :right, :char }
        @buffer.cursor.should eql("This is a sample buffer".length)
      end

    end

  end

end
