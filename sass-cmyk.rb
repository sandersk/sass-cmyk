  class CMYK < Sass::Script::Value::Base

    attr_reader :attrs

    # Attributes specified as a hash, representing CMYK percentages, i.e.
    # CMYK.new({:cyan=>10, :magenta=>20, :yellow=>30, :black=>40}) is equivalent to cmyk(10%,20%,30%,40%)
    def initialize(cmyk_attrs)
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

    def normalize
      # Return new CMYK object with normalized color components
      new_color_attrs = @attrs.merge(_normalize)
      CMYK.new(new_color_attrs)
    end

    def normalize!
      # Normalize color components in place
      @attrs.merge!(_normalize)
      self
    end

    def _normalize
      # Normalize color components via the following algorithm, per SO (http://stackoverflow.com/a/1530158)
      # C = C - min(C, M, Y)
      # M = M - min(C, M, Y)
      # Y = Y - min(C, M, Y)
      # K = min(100, K + min(C, M, Y))
      cmy_min = [@attrs[:cyan], @attrs[:magenta], @attrs[:yellow]].min
      new_attrs = {:cyan => @attrs[:cyan] - cmy_min,
                   :magenta => @attrs[:magenta] - cmy_min,
		   :yellow => @attrs[:yellow] - cmy_min,
		   :black => [100, @attrs[:black] + cmy_min].min}
    end

    

    # TODO: methods to do the following:
    # Add coverage for all the other instance methods in base that are necessary to override
    # Mix two CMYK colors (see http://stackoverflow.com/questions/1527451/cmyk-cmyk-cmyk-2)
    # Scale all components of CMYK color by given percentage

    def to_s(opts = {})
      "cmyk(#{@attrs[:cyan]}%,#{@attrs[:magenta]}%,#{@attrs[:yellow]}%,#{@attrs[:black]}%)" 
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

    CMYK.new(cmyk_attrs)
  end

  # TODO: DECLARE NEEDED HERE
end

module Sass::Script::Functions
  include CMYKLibrary
end



