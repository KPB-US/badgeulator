class RemovePictureFromBadge < ActiveRecord::Migration[4.2]
  def change
    remove_column :badges, :picture, :binary
  end
end
