class AddAttachmentPictureToBadges < ActiveRecord::Migration[4.2]
  def self.up
    change_table :badges do |t|
      t.attachment :picture
      t.attachment :card
    end
  end

  def self.down
    remove_attachment :badges, :picture
    remove_attachment :badges, :card
  end
end
