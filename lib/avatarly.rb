require 'pathname'
require 'mini_magick'

class Avatarly
  BACKGROUND_COLORS = [
      "#ff4040", "#7f2020", "#cc5c33", "#734939", "#bf9c8f", "#995200",
      "#4c2900", "#f2a200", "#ffd580", "#332b1a", "#4c3d00", "#ffee00",
      "#b0b386", "#64664d", "#6c8020", "#c3d96c", "#143300", "#19bf00",
      "#53a669", "#bfffd9", "#40ffbf", "#1a332e", "#00b3a7", "#165955",
      "#00b8e6", "#69818c", "#005ce6", "#6086bf", "#000e66", "#202440",
      "#393973", "#4700b3", "#2b0d33", "#aa86b3", "#ee00ff", "#bf60b9",
      "#4d3949", "#ff00aa", "#7f0044", "#f20061", "#330007", "#d96c7b"
    ].freeze

  class << self
    def generate_avatar(text, opts={})
      text = initials(text.to_s.strip.gsub(/[^\w ]/,'')).upcase
      generate_image(text, parse_options(opts))
    end

    def root
      File.expand_path '../..', __FILE__
    end

    def lib
      File.join root, 'lib'
    end

    private

    def fonts
      File.join root, 'assets/fonts'
    end

    def generate_image(text, opts)
      MiniMagick::Tool::Convert.new(whiny: false) do |convert|
        convert << '-size' << "#{opts[:size]}x#{opts[:size]}"
        convert << "xc:#{opts[:background_color]}"
        convert << '-pointsize' << opts[:font_size]
        convert << '-font' << opts[:font]
        convert << '-fill' << "#{opts[:font_color]}"
        convert << '-weight' << 300
        convert << '-gravity' << 'Center'
        convert << '-annotate' << opts[:vertical_offset] << text
        convert << 'png:-'
      end
    end

    def initials(text)
      initials_for_separator(text, " ")
    end

    def initials_for_separator(text, separator)
      if text.include?(separator)
        text = text.split(separator)
        text[0][0] + text[1][0]
      else
        text[0] || ''
      end
    end

    def default_options
      { background_color: BACKGROUND_COLORS.sample,
        font_color: 'white',
        size: 32,
        vertical_offset: 0,
        font: "#{fonts}/Roboto.ttf",
        format: "png" }
    end

    def parse_options(opts)
      opts = default_options.merge(opts)
      opts[:size] = opts[:size].to_i
      opts[:font] = default_options[:font] unless Pathname(opts[:font]).exist?
      opts[:font_size] ||= opts[:size] / 2
      opts[:font_size] = opts[:font_size].to_i
      opts[:vertical_offset] = opts[:vertical_offset].to_i
      opts
    end
  end
end
