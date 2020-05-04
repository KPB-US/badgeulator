class PrawnArtifactFont < PrawnArtifact
  def render(layout_guides)
    prawn.font value(badge)
  end
end
