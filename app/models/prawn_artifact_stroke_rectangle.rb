class PrawnArtifactStrokeRectangle < PrawnArtifact
  def render(layout_guides)
    prawn.line_width(3)
    color = prawn.stroke_color
    prawn.stroke_color = props[:color] if props.key?(:color)
    prawn.stroke_rounded_rectangle props[:at], props[:width], props[:height], 5
    prawn.stroke_color = color
  end
end
