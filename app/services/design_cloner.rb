# frozen_string_literal: true

# Clone the specified design.
class DesignCloner
  def initialize(original:)
    @original = original
  end

  def call
    new_design = clone_design
    original.sides.each do |side|
      new_side = new_design.sides.build(side.attributes)
      new_side.id = nil
      new_side.save!
      clone_artifacts(original_side: side, new_side: new_side)
    end
    new_design
  end

  private

  attr_reader :original

  def clone_artifacts(original_side:, new_side:)
    original_side.artifacts.each do |artifact|
      new_artifact = new_side.artifacts.build(artifact.attributes)
      new_artifact.id = nil
      if artifact.attachment.present?
        new_artifact.attachment = artifact.attachment
      end
      new_artifact.save!

      clone_properties(original_artifact: artifact, new_artifact: new_artifact)
    end
  end

  def clone_design
    new_design = Design.new(original.attributes)
    new_design.id = nil
    new_design.name += ' (copy)'
    if original.sample.present?
      new_design.sample = original.sample
    end
    new_design.save!
    new_design
  end

  def clone_properties(original_artifact:, new_artifact:)
    original_artifact.properties.each do |property|
      new_property = new_artifact.properties.build(property.attributes)
      new_property.id = nil
      new_property.save!
    end
  end
end
