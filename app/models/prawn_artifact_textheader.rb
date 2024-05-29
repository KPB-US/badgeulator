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
    at: props[:at]
    )    
  end
end