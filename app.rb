require 'sinatra'
require 'haml'
require 'pry'

class HSL
  def initialize(h, s, l)
    @hue = h.to_f
    @saturation = s.to_f
    @luminance = l.to_f
  end

  def to_hue
    h = (@hue / 360) * 65535
    s = @saturation * 255
    l = @luminance * 255
    {hue: h.to_i, saturation: s.to_i, luminance: l.to_i}
  end
end

class RGB

  attr_reader :red, :green, :blue

  def initialize(r, g, b)
    @red = r.to_f / 255
    @green = g.to_f / 255
    @blue = b.to_f / 255
    @max = [@red, @green, @blue].max
    @min = [@red, @green, @blue].min
  end
  
  def to_hsl
    l = self.luminance
    s = self.saturation
    h = self.hue
    HSL.new(h, s, l)
  end

  def to_hue
    to_hsl.to_hue
  end

  def to_hex
    "#{@red.to_s(16)}#{@green.to_s(16)}#{@blue.to_s(16)}"
  end

  def luminance
    @luminance ||= 0.5 * (@max + @min)
  end

  def saturation
    self.luminance unless @luminance
    if @max == @min
      @saturation ||= 0
    elsif @luminance <= 0.5
      @saturation ||= (@max - @min) / (2.0 * @luminance)
    else
      @saturation ||= (@max - @min) / (2.0 - 2.0 * @luminance)
    end
  end

  def hue
    if @saturation.zero?
      @hue ||= 0
    else
      case @max
      when red
        @hue ||= (60.0 * ((@green - @blue) / (@max - @min))) % 360.0
      when green
        @hue ||= 60.0 * ((@blue - @red) / (@max - @min)) + 120.0
      when blue
        @hue ||= 60.0 * ((@red - @green) / (@max - @min)) + 240.0
      end
    end
  end
end

class HexRGB < RGB
  def initialize(hex)
    hex = hex.scan(/../).map { |e| e.to_i(16) }
    super(hex[0], hex[1], hex[2])
  end
end


home = lambda do
  if params[:hex]
    hexrgb = HexRGB.new(params[:hex])
    hsl = RGB.new(hexrgb.red, hexrgb.green, hexrgb.blue).to_hsl.to_hue
    @hex = {hue: hsl[:hue], saturation: hsl[:saturation], luminance: hsl[:luminance]}.to_s
  end
  if params[:r]
    hsl = RGB.new(params[:r], params[:g], params[:b]).to_hsl.to_hue
    @rgb = {hue: hsl[:hue], saturation: hsl[:saturation], luminance: hsl[:luminance]}.to_s
  end
  haml :home
end
get  '/', &home
post '/', &home