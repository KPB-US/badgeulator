# frozen_string_literal: true

# Updates the user thumbnail photo in active directory.
class ActiveDirectoryPhotoUpdater
  require 'ldap_helper'
  include LdapHelper

  def initialize(distinguished_name:, image_path:)
    @dn = distinguished_name
    @image_path = image_path
  end

  def call
    with_ldap do |ldap|
      picture_data = File.binread(image_path)
      ldap.replace_attribute dn, :thumbnailPhoto, picture_data
      operation_result = ldap.get_operation_result
      if operation_result.code != 0
        raise StandardError, "Unable to update thumbnailPhoto for dn #{dn}: #{operation_result.message}"
      end
    end
  end

  private

  attr_reader :dn, :image_path
end
