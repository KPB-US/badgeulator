# frozen_string_literal: true

# Render card with or without badge.
class CardRenderer
  def initialize(design:)
    @design = design
  end

  def call(badge:, layout_guides:, update_sample:)
    first_side = design.sides.first
    p = Prawn::Document.new({
                              page_size: [first_side.width, first_side.height],
                              page_layout: first_side.orientation_name.downcase.to_sym,
                              margin: first_side.margin
                            })

    side_count = 0
    design.sides.each do |side|
      side_count += 1
      if side_count == 2
        # set up flip side
        p.start_new_page size: [side.width, side.height], layout: side.orientation_name.downcase.to_sym, margin: side.margin
      end

      if layout_guides
        p.stroke_bounds
        p.stroke_axis step_length: 20, color: '777777'
      end

      side.artifacts.includes(:properties).each do |artifact|
        # TODO! fix that we set the layout_guides flag here but act on it above
        if artifact.name.downcase == 'layout_guides'
          layout_guides = artifact.value == 'true'
          next
        end

        PrawnArtifact.from(artifact)
                     .new(prawn: p, artifact: artifact, badge: badge)
                     .render(layout_guides)
      end
    end

    if badge.id.blank?
      filename = "/tmp/design#{design.id}.pdf"
      p.render_file(filename)
    else
      filename = "/tmp/badge_#{badge.id}.pdf"
      p.render_file(filename)
      badge.card = File.open filename
      badge.save!
    end

    update_design_sample(filename) if update_sample

    File.delete filename
  end

  private

  attr_reader :design

  def update_design_sample(filename)
    design.sample = File.open(filename)
    design.save!
  end
end
