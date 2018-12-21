class AddUpdateThumbnailToBadge < ActiveRecord::Migration[4.2]
  def change
    add_column :badges, :update_thumbnail, :boolean, default: true
  end
end
