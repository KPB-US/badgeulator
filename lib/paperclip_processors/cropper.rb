module Paperclip
  class Cropper < Thumbnail
    def transformation_command
      uber = super
      crop_cmd = crop_command
      unless crop_cmd.blank?
        uber = crop_cmd + uber.join(' ').sub(/ -crop \S+/, '').split(' ')
      end

      uber
    end
    
    def crop_command
      cmd = []
      target = @attachment.instance
      if target.cropping?
        cmd = [" -crop '#{target.crop_region.width.to_i}x#{target.crop_region.height.to_i}+#{target.crop_region.x.to_i}+#{target.crop_region.y.to_i}'"]
      end

      cmd
    end
  end
end
