# frozen_string_literal: true

# Updates missing DNs.
class DistinguishedNamePopulator
  def self.call
    with_pictures(badges_missing_dns).each do |badge|
      employee_id = badge.employee_id
      entry = Badge.lookup_employee('employeeID', employee_id)
      if entry.present?
        update_dn(badge: badge, distinguished_name: entry[:dn])
      else
        Rails.logger.debug("cannot find AD entry for employeeID #{employee_id} for #{badge.id} #{badge.name}")
      end
    end
  end

  def self.badges_missing_dns
    Badge.where(dn: '', update_thumbnail: true).where.not(employee_id: [nil, '0', ''])
  end

  def self.update_dn(badge:, distinguished_name:)
    badge.dn = distinguished_name
    begin
      badge.update_ad_thumbnail
      badge.save
    rescue StandardError => e
      Rails.logger.error("Unable to update DN for badge #{badge.id}: #{e.message}")
    end
  end

  def self.with_pictures(badges)
    badges.to_a.keep_if { |badge| badge.picture.present? }
  end
end
