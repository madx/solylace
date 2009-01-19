require File.join( File.dirname(__FILE__), '..', 'lib', 'solylace' )
include Solylace

describe Configuration do
  
  describe ".defaults" do
    it "should return a kind of metash" do
      Configuration.defaults.should be_a_kind_of(Metash)
    end

    it "should be populated with defaults" do
      Configuration.defaults.theme.should eql(:default)
    end
  end

  describe ".build" do

    before(:each) do
      @configuration = Configuration.build {
        set :auto_indent
        set :tab_width, 4
        set :font, "Monaco 10px"

        path :shoes, "/usr/local/bin/shoes"

        theme :custom
      }
    end

    it "should return the resulting Configuration" do
      @configuration.should be_a_kind_of(Metash)
    end
    
    it "should apply the DSL evalutation" do
      @configuration.__hash.should_not eql(Configuration.defaults.__hash)
    end

  end

end
