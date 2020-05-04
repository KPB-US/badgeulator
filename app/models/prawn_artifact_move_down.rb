class PrawnArtifactMoveDown < PrawnArtifact
  def render(layout_guides)
    prawn.move_down value(badge).to_i
  end
end
