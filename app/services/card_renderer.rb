class CardRenderer
  def initialize(design:)
    @design = design
  end

  def call(badge:, layout_guides:, update_sample:)
    # TODO! doument should have custom properties too
    first_side = design.sides.first
    p = Prawn::Document.new({
      page_size: [first_side.width, first_side.height],
      page_layout: first_side.orientation_name.downcase.to_sym,
      margin: first_side.margin })

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
          layout_guides = artifact.value == "true"
          next
        end

        # build the properties
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
              if v == "{cursor}"
                value << p.cursor
              elsif v == "{width}"
                value << p.bounds.width
              elsif v == "{height}"
                value << p.bounds.height
              else
                value << v.to_i
              end
            end
          elsif [:width].include?(name)
            if property.value.downcase == "{width}"
              value = p.bounds.width
            elsif property.value.downcase == "{remaining}"
              value = p.bounds.right
              offset = 0
              offset = props[:left] if props.key?(:left)
              offset = props[:at].first if props.key?(:at)
              value = value - offset
            else
              value = property.value.to_i
            end
          elsif [:height].include?(name)
            if property.value.downcase == "{height}"
              value = p.bounds.height
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
              value = property.value.to_i rescue 0
            end
          elsif [:final_gap, :fit].include?(name)
            value = property.value == "true"
          end
          props[name] = value
        end
        # post property processing because fit needs width and height
        if props.key?(:fit) && props.key?(:width) && props.key?(:height)
          props[:fit] = [props[:width], props[:height]]
        end


        # render the artifact

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

        value = artifact.value
        value = value.gsub("{employee_id}", badge.employee_id)
        value = value.gsub("{name}", badge.name)
        value = value.gsub("{first_name}", badge.first_name)
        value = value.gsub("{last_name}", badge.last_name)
        value = value.gsub("{department}", badge.department)
        value = value.gsub("{title}", badge.title)
        # where there is no image, bobby badger will appear
        value = value.gsub("{photo}", (badge.picture.blank? ? Rails.root.join('app', 'assets', 'images', 'badger_300r.jpg').to_s : badge.picture.path(:badge)))
        value = value.gsub("{attachment}", artifact.attachment.path) unless artifact.attachment.blank?

        if false
        elsif artifact.name == "fill_gradient"
          p.fill_gradient props[:from], props[:to], props[:color1], props[:color2]
        elsif artifact.name == "fill_rectangle"
          color = p.fill_color
          p.fill_color = props[:color] if props.key?(:color)
          p.fill_rectangle props[:at], props[:width], props[:height]
          p.fill_color = color
        elsif artifact.name == "font"
          p.font value
        elsif artifact.name == "image"
          if !File.exist?(value)
            if props.key?(:at) && props.key?(:height) && props.key?(:width)
              p.stroke_rectangle props[:at], props[:width], props[:height]
              p.text_box value, props
            else
              p.text value
            end
          else
            p.image value, props
          end
        elsif artifact.name == "move_down"
          p.move_down value.to_i
        elsif artifact.name == "move_up"
          p.move_up value.to_i
        elsif artifact.name == "textbox" || artifact.name == "text_box"
          if layout_guides
            color = p.stroke_color
            p.stroke_color 'AAAAAA'
            p.stroke_rectangle props[:at], props[:width], props[:height]
            p.stroke_color color
          end

          p.text_box value, props
          p.move_down props[:height] if props.key?(:height)
        end

        #puts "#{artifact.name} #{artifact.value}, #{props}"
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

    if update_sample
      design.sample = File.open filename
      design.save!
    end

    File.delete filename
  end

  private

  attr_reader :design
end
