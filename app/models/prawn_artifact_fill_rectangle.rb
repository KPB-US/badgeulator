class PrawnArtifactFillRectangle < PrawnArtifact
  def render(layout_guides)
    if props.key?(:at) && props.key?(:height) && props.key?(:width)
      color = prawn.fill_color
      prawn.fill_color = props[:color] if props.key?(:color)
      prawn.fill_rectangle props[:at], props[:width], props[:height]
      prawn.fill_color = color
    else
      prawn.text artifact.name + " id " + artifact.id.to_s + ' needs at, width, height.', color: 'FF0000', size: 10
    end
  end
end
