class Badge < ActiveRecord::Base
  has_attached_file :picture, styles: { badge: "300x400>", thumb: ["96x96#", :png] }, processors: [:cropper]
  has_attached_file :card, styles: { preview: { geometry: "318x200>", format: :png, convert_options: "-png" } }, processors: [:pdftoppm]

  attr_accessor :crop_x, :crop_y, :crop_h, :crop_w

  validates_attachment :picture, content_type: { content_type: "image/jpeg" }
  validates_attachment :card, content_type: { content_type: "application/pdf" }

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :department, presence: true
  validates :title, presence: true
  validates :employee_id, presence: true

  def cropping?
    return !crop_x.blank?
  end

  def picture_geometry(style = :original)
    @geometry ||= {}
    @geometry[style] ||= Paperclip::Geometry.from_file(picture.path(style))
  end

  def self.ad_lookup(attribute, value)
    entry = nil
    if ENV["USE_LDAP"] == "true"
      require 'net/ldap'

      ldap_config = YAML.load(ERB.new(File.read(Devise.ldap_config || "#{Rails.root}/config/ldap.yml")).result)[Rails.env]
      ldap_config["ssl"] = :simple_tls if ldap_config["ssl"] === true
      ldap_options = {}
      ldap_options[:encryption] = ldap_config["ssl"].to_sym if ldap_config["ssl"]

      ldap = Net::LDAP.new(ldap_options)
      ldap.host = ldap_config["host"]
      ldap.port = ldap_config["port"]
      ldap.base = ldap_config["base"]
      ldap.auth ldap_config["admin_user"], ldap_config["admin_password"] 

      if ldap.bind
        # active_filter = Net::LDAP::Filter.construct("(&
        #     (|(mail=*@kpb.us)(mail=*@borough.kenai.ak.us))
        #     (objectCategory=person)
        #     (objectClass=user)
        #     (givenName=*)
        #     (!(userAccountControl:1.2.840.113556.1.4.803:=2)))")
        results = ldap.search(
          filter: "(#{attribute}=#{value})",      # active_filter, 
          attributes: %w(givenname mail dn sn employeeID manager title department thumbnailPhoto) )
          Rails.logger.debug("#{results.size} results found")        
        if results.size == 1
          entry = results.first
        end
      end
    end

    entry
  end

  # must populate dn for ad thumbnail to be updated
  def self.lookup_employee(attribute, value)
    info = {}

    if ENV["USE_LDAP"] == "true"
      Rails.logger.debug("using ldap employee lookup")

      entry = ad_lookup(attribute, value)
      unless entry.blank?
        info = {
          first_name: entry.givenname.first,
          last_name:  entry.sn.first,
          department: entry.department.first,
          title: entry.title.first,
          employee_id: entry.employeeid.first,
          dn: entry.dn
        }
      end
    else
      Rails.logger.debug("no employee lookup defined")
    end
    
    info
  end

  def name
    "#{first_name} #{last_name}"
  end

  def update_ad_thumbnail
    return if ENV["USE_LDAP"] != "true" || dn.blank?

    require 'net/ldap'
    ldap_config = YAML.load(ERB.new(File.read(Devise.ldap_config || "#{Rails.root}/config/ldap.yml")).result)[Rails.env]
    ldap_config["ssl"] = :simple_tls if ldap_config["ssl"] === true
    ldap_options = {}
    ldap_options[:encryption] = ldap_config["ssl"].to_sym if ldap_config["ssl"]
    ldap_options[:host] = ldap_config["host"]
    ldap_options[:port] = ldap_config["port"]
    ldap_options[:base] = ldap_config["base"]
    ldap_options[:auth] = { method: :simple, username: ldap_config["admin_user"], password: ldap_config["admin_password"] }
    ldap = Net::LDAP.new(ldap_options)
    ldap.open do |ldap|
      picture_data = File.binread(picture.path(:thumb))
      ldap.replace_attribute dn, :thumbnailPhoto, picture_data
      raise Exception, "unable to update thumbnailPhoto - #{ldap.get_operation_result.message}" if ldap.get_operation_result.code != 0
    end
  end
end
