class RenameLogoToAttachmentInArtifacts < ActiveRecord::Migration[4.2]
  def change
    rename_column :artifacts, :logo_file_name, :attachment_file_name
    rename_column :artifacts, :logo_content_type, :attachment_content_type
    rename_column :artifacts, :logo_file_size, :attachment_file_size
    rename_column :artifacts, :logo_updated_at, :attachment_updated_at
  end
end
