class PrawnArtifact
  def initialize(prawn:, artifact:, badge:)
    @artifact = artifact
    @badge = badge
    @prawn = prawn

    @props = fetch_artifact_properties
  end

  def self.artifact_mapping
    {
      'layout_guides' => PrawnArtifactNull,
      'fill_gradient' => PrawnArtifactFillGradient,
      'fill_rectangle' => PrawnArtifactFillRectangle,
      'font' => PrawnArtifactFont,
      'image' => PrawnArtifactImage,
      'move_down' => PrawnArtifactMoveDown,
      'move_up' => PrawnArtifactMoveUp,
      'textbox' => PrawnArtifactTextbox,
      'text_box' => PrawnArtifactTextbox,
      'null' => PrawnArtifactNull
    }
  end

  def self.from(artifact)
    artifact_mapping[artifact.name] || PrawnArtifactNull
  end

  def value(badge)
    interpolate_value(badge)
  end

  private

  attr_reader :artifact, :badge, :props, :prawn

  def fetch_artifact_properties
    props = {}
    # TODO! these properties/value formats/ranges need to be validated when saved
    artifact.properties.each do |property|
      name = property.name.downcase.to_sym
      value = property.value
      # make sure value is in the right format
      if [:at, :from, :to].include?(name)
        value = []
        property.value.downcase.split(',').each do |v|
          v = v.strip
          if v == '{cursor}'
            value << prawn.cursor
          elsif v == '{width}'
            value << prawn.bounds.width
          elsif v == '{height}'
            value << prawn.bounds.height
          else
            value << v.to_i
          end
        end
      elsif [:width].include?(name)
        if property.value.downcase == '{width}'
          value = prawn.bounds.width
        elsif property.value.downcase == '{remaining}'
          value = prawn.bounds.right
          offset = 0
          offset = props[:left] if props.key?(:left)
          offset = props[:at].first if props.key?(:at)
          value = value - offset
        else
          value = property.value.to_i
        end
      elsif [:height].include?(name)
        if property.value.downcase == '{height}'
          value = prawn.bounds.height
        else
          value = property.value.to_i
        end
      elsif [:size, :rotate, :up, :down].include?(name)
        value = property.value.to_i
      elsif [:overflow, :style, :align, :valign].include?(name)
        value = property.value.downcase.to_sym
      elsif [:position, :vposition].include?(name)
        value = property.value.downcase.to_sym
        if ![:left, :center, :right, :top, :center, :bottom].include?(value)
          begin
            value = property.value.to_i
          rescue
            value = 0
          end
        end
      elsif [:final_gap, :fit].include?(name)
        value = property.value == 'true'
      end
      props[name] = value
    end

    # post property processing because fit needs width and height
    if props.key?(:fit) && props.key?(:width) && props.key?(:height)
      props[:fit] = [props[:width], props[:height]]
    end

    # make adjustments to position based on our custom :up or :down props
    if props.key?(:at)
      if props.key?(:up)
        props[:at][1] += props[:up]
        props.delete :up
      end
      if props.key?(:down)
        props[:at][1] -= props[:down]
        props.delete :down
      end
    end

    props
  end

  def interpolate_value(badge)
    artifact.value.
      gsub('{employee_id}', badge.employee_id).
      gsub('{name}', badge.name).
      gsub('{first_name}', badge.first_name).
      gsub('{last_name}', badge.last_name).
      gsub('{department}', badge.department).
      gsub('{title}', badge.title).
      gsub('{photo}', (badge.picture.blank? ? Rails.root.join('app', 'assets', 'images', 'badger_300r.jpg').to_s : badge.picture.path(:badge))).
      gsub('{attachment}', artifact.attachment.blank? ? '{attachment}' : artifact.attachment.path)
  end
end
