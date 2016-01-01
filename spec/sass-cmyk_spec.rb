# encoding: utf-8
require 'sass'
require_relative '../sass-cmyk.rb'

describe "Sass CMYK object" do

  it "should be successfully instantiated with CMYK values" do
     cmyk_color = CMYK.new({:cyan=>10, :magenta=>20, :yellow=>30, :black=>40})
     cmyk_color.class.should == CMYK
  end

  it "should raise an error when instantiated with one or more CMYK values missing" do
    expect{ CMYK.new({:cyan=>10, :magenta=>0, :yellow=>3})}.to raise_error(ArgumentError)
  end

  it "should raise an error when instantiated with invalid value (over 100) for one or more CMYK components" do
    expect{ CMYK.new({:cyan=>10, :magenta=>0, :yellow=>3, :black=>120})}.to raise_error(ArgumentError)
  end

  it "should raise an error when instantiated with invalid value (less than 0) for one or more CMYK components" do
    expect{ CMYK.new({:cyan=>10, :magenta=>0, :yellow=>-2, :black=>100})}.to raise_error(ArgumentError)
  end

  it "should raise an error when instantiated with invalid value (non-integer) for one or more CMYK components" do
    expect{ CMYK.new({:cyan=>10, :magenta=>0, :yellow=>20.5, :black=>100})}.to raise_error(ArgumentError)
  end

  describe "instance methods" do
    
    before(:each) do
      @dummy_color = CMYK.new({:cyan=>20, :magenta=>40, :yellow=>60, :black=>70})
      @dummy_color_already_normalized = CMYK.new({:cyan=>0, :magenta=>30, :yellow=>10, :black=>20})
    end

    it "should be able to return its attrs" do
      @dummy_color.attrs.should == {:cyan=>20, :magenta=>40, :yellow=>60, :black=>70}
    end

    it "should be able to return Cyan component percentage" do
      @dummy_color.cyan.should == 20
    end

    it "should be able to return Magenta component percentage" do
      @dummy_color.magenta.should == 40
    end

    it "should be able to return Yellow component percentage" do
      @dummy_color.yellow.should == 60
    end

    it "should be able to return Black (K) component percentage" do
      @dummy_color.black.should == 70
    end

    it "should convert to String as CSS function in format cmyk(nn%,nn%,nn%,nn%)" do
      @dummy_color.to_s.should == "cmyk(20%,40%,60%,70%)"
    end

    it "should be able to normalize CMYK color components (C+M+Y => K) (in place)" do
      @dummy_color.normalize!
      @dummy_color.attrs.should == {:cyan=>0, :magenta=>20, :yellow=>40, :black=>90}
    end

    it "should be able to normalize CMYK color components (C+M+Y => K) (returning new CMYK color)" do
      new_color = @dummy_color.normalize
      new_color.attrs.should == {:cyan=>0, :magenta=>20, :yellow=>40, :black=>90}
    end

    it "should not change CMYK color components when normalizing (in place) in cases where 1 or more components has zero value" do
      @dummy_color_already_normalized.normalize!
      @dummy_color_already_normalized.attrs.should == {:cyan=>0, :magenta=>30, :yellow=>10, :black=>20}
    end

    it "should not change CMYK color components when normalizing (returning new CMYK color) in cases where 1 or more components has zero value" do
      new_color = @dummy_color_already_normalized.normalize
      new_color.should == @dummy_color_already_normalized
    end

  end
  
end
