# frozen_string_literal: true

# Look up an employee in active directory.
class ActiveDirectoryEmployeeFetcher
  require 'ldap_helper'
  extend LdapHelper

  def self.find(attribute:, value:)
    entry = ad_lookup(attribute: attribute, value: value)
    return {} if entry.blank?

    {
      first_name: entry.givenname.first,
      last_name: entry.sn.first,
      department: entry.department.first,
      title: entry.title.first,
      employee_id: entry.employeeid.first,
      dn: entry.dn
    }
  end

  def self.ad_lookup(attribute:, value:)
    results = with_ldap do |ldap|
      ldap.search(
        filter: "(#{attribute}=#{value})",
        attributes: %w[givenname mail dn sn employeeID manager title department thumbnailPhoto]
      )
    end
    (results.size == 1 ? results.first : nil)
  end
end
