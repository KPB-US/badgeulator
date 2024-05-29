# frozen_string_literal: true

require 'ldap_helper'
# Badge table.
class Badge < ApplicationRecord
  include LdapHelper

  has_attached_file :picture,
                    styles: {
                      original: '',
                      badge: '300x400>',
                      thumb: ['96x96#', :png]
                    },
                    processors: [:cropper],
                    source_file_options: { all: '-auto-orient' },
                    convert_options: { thumb: '-quality 85 -strip' }

  has_attached_file :card,
                    styles: {
                      preview: {
                        geometry: '318x200>',
                        format: :png,
                        convert_options: '-png'
                      }
                    },
                    processors: [:pdftoppm]

  default_scope { order(created_at: :desc) }

  attr_reader :crop_region

  validates_attachment :picture, content_type: { content_type: ['image/jpeg', 'image/png'] }
  validates_attachment :card, content_type: { content_type: 'application/pdf' }

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :department, presence: true
  validates :title, presence: true
  validates :employee_id, presence: true
  # validates :unique_id, presence: true

  # Define a rectangle region.
  Rectangle = Struct.new(:x, :y, :width, :height)

  def self.sample
    Badge.new({
      employee_id: '9999',
      first_name: 'First Name',
      last_name: 'Last Name',
      title: 'The Title',
      department: 'The Department'
    })
  end

  # of the badges that have a photo and a card, get the most recent per employee_id
  def self.complete
    where('picture_file_size > 0 and card_file_size > 0
      and id = (select max(id)
        from badges b
        where b.employee_id = badges.employee_id and b.picture_file_size > 0 and b.card_file_size > 0)')
  end

  def set_crop_region(x:, y:, width:, height:)
    @crop_region = Rectangle.new(x, y, width, height)
  end

  def cropping?
    !crop_region.blank?
  end

  def picture_geometry(style = :original)
    @geometry ||= {}
    @geometry[style] ||= Paperclip::Geometry.from_file(picture.path(style))
  end

  # must populate dn for ad thumbnail to be updated
  def self.lookup_employee(attribute, value)
    info = {}

    if ENV['USE_LDAP'] == 'true'
      info = ActiveDirectoryEmployeeFetcher.find(attribute: attribute, value: value)
    end

    info
  end

  def name
    "#{first_name} #{last_name}"
  end

  def update_ad_thumbnail
    return if not_ldappable?

    ActiveDirectoryPhotoUpdater.new(distinguished_name: dn, image_path: picture.path(:thumb)).call
  end

  def update_payroll_thumbnail
    if !picture.blank? && !employee_id.blank? && wants_thumbnail_updated?
      PayrollPhotoUpdater.new(badge: self).call
    end
  end

  private

  def not_ldappable?
    !using_ldap? || !dn_present? || !wants_thumbnail_updated?
  end

  def using_ldap?
    ENV['USE_LDAP'] == 'true'
  end

  def dn_present?
    dn.present?
  end

  def wants_thumbnail_updated?
    update_thumbnail == true
  end
end
