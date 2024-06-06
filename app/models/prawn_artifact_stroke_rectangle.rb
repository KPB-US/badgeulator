class PrawnArtifactStrokeRectangle < PrawnArtifact
  def render(layout_guides)
    if props.key?(:at) && props.key?(:height) && props.key?(:width) && props.key?(:line_width) && props.key?(:radius) && props.key?(:color)
      prawn.line_width(props[:line_width])
      prawn.stroke_color = props[:color] 
      prawn.stroke_rounded_rectangle props[:at], props[:width], props[:height], props[:radius].to_i
    else
      prawn.text artifact.name + " id " + artifact.id.to_s + ' needs at, width, height, radius, line_width, color.', color: 'FF0000', size: 10
    end

  end
end
