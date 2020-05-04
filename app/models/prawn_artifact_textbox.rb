class PrawnArtifactTextbox < PrawnArtifact
  def render(layout_guides)
    if layout_guides
      color = prawn.stroke_color
      prawn.stroke_color 'AAAAAA'
      prawn.stroke_rectangle props[:at], props[:width], props[:height]
      prawn.stroke_color color
    end

    prawn.text_box value(badge), props
    prawn.move_down props[:height] if props.key?(:height)
  end
end
