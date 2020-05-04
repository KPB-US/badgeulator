class PrawnArtifactImage < PrawnArtifact
  def render(layout_guides)
    image_path = value(badge)
    if !File.exist?(image_path)
      if props.key?(:at) && props.key?(:height) && props.key?(:width)
        prawn.stroke_rectangle props[:at], props[:width], props[:height]
        prawn.text_box image_path, props
      else
        prawn.text image_path
      end
    else
      prawn.image image_path, props
    end
  end
end
