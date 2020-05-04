class PrawnArtifactFillGradient < PrawnArtifact
  def render(layout_guides)
    prawn.fill_gradient props[:from], props[:to], props[:color1], props[:color2]
  end
end
