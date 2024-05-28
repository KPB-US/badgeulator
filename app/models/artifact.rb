class Artifact < ApplicationRecord
  belongs_to :side
  has_many :properties, dependent: :destroy

  has_attached_file :attachment

  default_scope { order({ side_id: :asc, order: :asc, name: :asc }) }

  accepts_nested_attributes_for :properties, reject_if: :all_blank, allow_destroy: true

  validates :name, presence: true
  validates :order, presence: true
  # only attachment types that prawn can handle
  validates_attachment :attachment, content_type: {
    content_type: ['image/jpeg', 'image/png', 'application/x-font-ttf', 'application/x-font-truetype','font/ttf']
  }

  after_save :reorder
  after_destroy :reorder

  def prior
    Artifact.where('side_id = :side and "order" < :order', side: side_id, order: order).last
  end

  private

  def reorder
    side.reorder_artifacts
  end
end
