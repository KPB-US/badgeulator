class PrawnArtifactFillGradient < PrawnArtifact
  def render(layout_guides)
    if props.key?(:from) && props.key?(:to) && props.key?(:color1) && props.key?(:color2) 
      prawn.fill_gradient props[:from], props[:to], props[:color1], props[:color2]
    else
      prawn.text artifact.name + " id " + artifact.id.to_s + ' needs from, to, color1 and color2.', color: 'FF0000', size: 10
    end
  end
end
