class AddAttachmentSampleToDesigns < ActiveRecord::Migration[4.2]
  def self.up
    change_table :designs do |t|
      t.attachment :sample
    end
  end

  def self.down
    remove_attachment :designs, :sample
  end
end
