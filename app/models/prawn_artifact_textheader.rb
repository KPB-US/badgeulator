class PrawnArtifactTextheader < PrawnArtifact
  def render(layout_guides)
    prawn.text value(badge), color: props[:color],  size: props[:size]
    # , style: props[:style]
  end
end