require 'sass'

module CMYKClass

  class CMYK < Sass::Script::Value::Base

    attr_reader :attrs

    # Attributes specified as a hash, representing CMYK percentages, i.e.
    # Sass::Script::Value::CMYK.new({:cyan=>10, :magenta=>20, :yellow=>30, :black=>40}) is equivalent to cmyk(10%,20%,30%,40%)
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
      Sass::Script::Value::CMYK.new(new_color_attrs)
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

    def plus(other)
      if other.is_a?(Sass::Script::Value::CMYK)
        new_color_attrs = {}
        [:cyan, :magenta, :yellow, :black].each do |component|
	  # Add corresponding components of each color, limiting to a max of 100
	  component_sum = [self.attrs[component] + other.attrs[component], 100].min
	  new_color_attrs[component] = component_sum
	end
	# Make new color from summed componenets
	new_color = Sass::Script::Value::CMYK.new(new_color_attrs)
	# Normalize component values
	new_color.normalize!
      else
        raise ArgumentError.new("Cannot add object of class #{other.class} to CMYK color #{self}. Only CMYK colors can be added to CMYK colors")
      end
    end

    def minus(other)
      raise NoMethodError.new("Cannot apply subtraction to #{self}. Subtraction not supported for CMYK colors.")
    end

    # TODO: This does not work commutatively yet; only works for CMYK * scalar, and not scalar * CMYK
    # To add support for scalar * CMYK, need to override "times" instance method on Sass::Script::Value::Number
    def times(other)
      if other.is_a?(Sass::Script::Value::Number)
        scale_factor = other.value
        new_color_attrs = {}
        [:cyan, :magenta, :yellow, :black].each do |component|
	  # Scale corresponding components of each color by "scale_factor"
	  new_color_attrs[component] = (self.attrs[component] * scale_factor).round
	end
	# Raise error if any resulting component attribute is over 100%, as that would mean it's not possible to scale proportionally
	raise ArgumentError.new("Cannot scale #{self} proportionally by #{other}, as that would result in at least one component over 100%") if new_color_attrs.map {|k, v| v}.max > 100
	# Make new color from scaled components
	new_color = Sass::Script::Value::CMYK.new(new_color_attrs)
	# Normalize component values
	new_color.normalize!
      else
        raise ArgumentError.new("Cannot multiply #{self} by #{other}. CMYK colors can only be multiplied by numbers")
      end
    end

    def div(other)
      raise ArgumentError.new("Cannot divide #{self} by #{other}. CMYK colors can only be divided by numbers") if !other.is_a?(Sass::Script::Value::Number)
      raise ArgumentError.new("Cannot divide CMYK color #{self} by zero") if other.value == 0
      reciprocal = Sass::Script::Value::Number.new(1.0/other.value)
      self.times(reciprocal)
    end

    def to_s(opts = {})
      "cmyk(#{@attrs[:cyan]}%,#{@attrs[:magenta]}%,#{@attrs[:yellow]}%,#{@attrs[:black]}%)" 
    end
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

      if comp_value_normalized.is_a?(Fixnum) && comp_value_normalized.between?(0, 100)
        [comp_name, comp_value_normalized]
      else
        raise ArgumentError.new("Invalid #{comp_name} value #{comp_value}. Must be a float between 0 and 1 or a percent between 0 and 100.")
      end
    end

    cmyk_attrs = Hash[cmyk_arr]

    Sass::Script::Value::CMYK.new(cmyk_attrs)
  end

  Sass::Script::Functions.declare :cmyk, [:cyan, :magenta, :yellow, :black]

  def cmyk_mix(cmyk_color1, cmyk_color2)
    raise ArgumentError.new("Bad arguments to cmyk_mix: #{cmyk_color1}, #{cmyk_color2}. cmyk_mix requires two CMYK colors as arguments") unless (cmyk_color1.is_a?(Sass::Script::Value::CMYK) && cmyk_color2.is_a?(Sass::Script::Value::CMYK))
    cmyk_color1.plus(cmyk_color2)
  end

  Sass::Script::Functions.declare :cmyk_mix, [:cmyk1, :cmyk2]

  def cmyk_scale(cmyk_color, percent)
    raise ArgumentError.new("Bad argument to cmyk_scale: #{cmyk_color}. First argument must be a CMYK color") unless cmyk_color.is_a?(Sass::Script::Value::CMYK)
    raise ArgumentError.new("Bad argument to cmyk_scale: #{percent}. Second argument must be a percent") unless (percent.is_a?(Sass::Script::Value::Number) && percent.is_unit?('%'))
    scale_factor_normalized = percent.value.to_f / 100
    cmyk_color.times(Sass::Script::Value::Number.new(scale_factor_normalized))
  end

  Sass::Script::Functions.declare :cmyk_scale, [:cmyk, :percent]

end

module Sass::Script::Functions
  include CMYKLibrary
end

module Sass::Script::Value
  include CMYKClass
end


