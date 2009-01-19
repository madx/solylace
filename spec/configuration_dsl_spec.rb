require File.join( File.dirname(__FILE__), '..', 'lib', 'solylace' )
include Solylace

describe ConfigurationDSL do

  describe ".new" do
    it "should take a default hash" do
      cfg = ConfigurationDSL.new :foo => :bar
      cfg.__hash.should eql({:foo => :bar})
    end
  end

  describe "#set" do
    before :each do
      @config = ConfigurationDSL.new :foo => :bar
    end
    it "should change a value of @hash" do
      @config.set :foo, :baz
      @config.__hash[:foo].should eql(:baz)
    end

    it "should use true as a default value" do
      @config.set :foo
      @config.__hash[:foo].should be_true
    end
  end

  describe "#path" do
    it "should change the path for a given item" do
      config = ConfigurationDSL.new :paths => {:foo => :bar}
      config.path :foo, :baz
      config.__hash[:paths][:foo].should eql(:baz)
    end
  end

  describe "#__hash" do
    it "should return the internal hash" do
      config = ConfigurationDSL.new :foo => :bar
      config.__hash.should eql({:foo => :bar})
    end
  end

end
