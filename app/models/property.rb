class Property < ApplicationRecord
  belongs_to :artifact

  # ALLOWED = [
  #   "align",
  #   "at",
  #   "bottom",
  #   "center",
  #   "color",
  #   "color1",
  #   "color2",
  #   "down",
  #   "final_gap",
  #   "fit",
  #   "from",
  #   "height",
  #   "left",
  #   "overflow",
  #   "position",
  #   "right",
  #   "rotate",
  #   "size",
  #   "style",
  #   "to",
  #   "top",
  #   "up",
  #   "valign",
  #   "vposition",
  #   "width"
  # ].freeze

  default_scope { order( { artifact_id: :asc, name: :asc } ) }

  validates :name, presence: true

end
