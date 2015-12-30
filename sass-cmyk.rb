  class CMYK < Sass::Script::Value::Base

    attr_reader :attrs

    # Attributes specified as a hash, representing CMYK percentages, i.e.
    # CMYK.new({:cyan=>10, :magenta=>20, :yellow=>30, :black=>40}) is equivalent to cmyk(10%,20%,30%,40%)
    def initialize(cmyk_attrs, prefix=nil)
      # Reject all attribute values that are not numbers between 0 and 100
      cmyk_attrs.reject! {|k, v| !(v.class == Fixnum and v.between?(0, 100))}
      raise ArgumentError.new("CMYK Object must be initialized with hash values between 0 and 100 for :cyan, :magenta, :yellow, and :black") unless [:cyan, :magenta, :yellow, :black].all? {|k| cmyk_attrs.key? k}
      @attrs = cmyk_attrs        
    end

    def cyan
      @attrs[:cyan]
    end

    def magenta
      @attrs[:magenta]
    end

    def yellow
      @attrs[:yellow]
    end

    def black
      @attrs[:black]
    end

    # TODO: methods to do the following:
    # Normalize (replace, CMYK with corresponding amount of black
    # Mix two CMYK colors (see http://stackoverflow.com/questions/1527451/cmyk-cmyk-cmyk-2)
    # Scale all components of CMYK color by given percentage

    def to_s
      #TODO: Fill in code here
      "PLACEHOLDER"
    end
  end

module CMYKLibrary
  def cmyk(c, m, y, k)
    cmyk_arr = [[:cyan, c], [:magenta, m], [:yellow, y], [:black, k]].map do |(comp_name, comp_value)|
      assert_type comp_value, :Number, comp_name
      if comp_value.is_unit?("%")
        comp_value_normalized = comp_value.value
      else
        comp_value_normalized = (comp_value.value * 100).round
      end

      if !(comp_value_normalized.between?(0, 100))
        raise ArgumentError.new("Invalid #{comp_name} value #{comp_value}. Must be a float between 0 and 1 or a percent between 0 and 100.")
      else
        [comp_name, comp_value_normalized]
      end
    end

    cmyk_attrs = Hash[cmyk_arr]
    puts cmyk_attrs

    CMYK.new(cmyk_attrs)
  end

  # TODO: DECLARE NEEDED HERE
end

module Sass::Script::Functions
  include CMYKLibrary
end




