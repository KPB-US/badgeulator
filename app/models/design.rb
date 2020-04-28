# frozen_string_literal: true

# Badge Design (layout) table.
class Design < ApplicationRecord
  has_many :sides, dependent: :destroy

  has_attached_file :sample,
                    styles: {
                      preview: { geometry: '318x200>', format: :png, convert_options: '-png' }
                    },
                    processors: [:pdftoppm]

  accepts_nested_attributes_for :sides, reject_if: :all_blank, allow_destroy: true

  default_scope { order(name: :asc) }

  validates :name, presence: true
  validates_attachment :sample, content_type: { content_type: 'application/pdf' }

  # returns the default active card design
  def self.selected
    Design.find_by(default: true)
  end

  def render_card(badge: Badge.sample, layout_guides: false, update_sample: false)
    return if sides.empty?

    CardRenderer.new(design: self).call(badge: badge, layout_guides: layout_guides, update_sample: update_sample)
  end

  def clone
    DesignCloner.new(original: self).call
  end
end
