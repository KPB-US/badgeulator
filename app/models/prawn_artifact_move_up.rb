class PrawnArtifactMoveUp < PrawnArtifact
  def render(layout_guides)
    prawn.move_up value(badge).to_i
  end
end
