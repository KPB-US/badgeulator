class PrawnArtifactFillRectangle < PrawnArtifact
  def render(layout_guides)
    color = prawn.fill_color
    prawn.fill_color = props[:color] if props.key?(:color)
    prawn.fill_rectangle props[:at], props[:width], props[:height]
    prawn.fill_color = color
  end
end
