class Artifact < ApplicationRecord
  # def self.ALLOWED
  #   [
  #   'layout_guides',
  #   'fill_gradient',
  #   'fill_rectangle',
  #   'font',
  #   'image',
  #   'move_down',
  #   'move_up',
  #   'text_box',
  #   'textbox'
  #   ]
  # end

  belongs_to :side
  has_many :properties, dependent: :destroy

  has_attached_file :attachment

  default_scope { order({ side_id: :asc, order: :asc, name: :asc }) }

  accepts_nested_attributes_for :properties, reject_if: :all_blank, allow_destroy: true

  validates :name, presence: true
  validates :order, presence: true
  # only attachment types that prawn can handle
  validates_attachment :attachment, content_type: {
    content_type: ['image/jpeg', 'image/png', 'application/x-font-ttf', 'application/x-font-truetype']
  }

  after_save :reorder
  after_destroy :reorder

  def reorder
    side.reorder_artifacts
  end
end
