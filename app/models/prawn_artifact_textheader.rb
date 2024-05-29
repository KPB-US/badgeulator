class PrawnArtifactTextheader < PrawnArtifact
  def render(layout_guides)
    prawn.formatted_text_box(
      [
      {
        text: value(badge),
        color: props[:color],  
        size: props[:size]
      },
    ],
    at: props[:at],
    align: props[:align],
    valign: props[:valign],
    overflow: props[:overflow],
    height: props[:height],
    width: props[:width]
    )    
  end
end