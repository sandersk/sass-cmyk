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
      @dummy_color = CMYK.new({:cyan=>20, :magenta=>40, :yellow=>60, :black=>80})
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
      @dummy_color.black.should == 80
    end

  end
  
end
