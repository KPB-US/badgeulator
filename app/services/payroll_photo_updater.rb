# frozen_string_literal: true

# Update employee's thumbnail in innoprise payroll.
class PayrollPhotoUpdater
  require 'tiny_tds'

  def initialize(badge:)
    @badge = badge
    @client = TinyTds::Client.new(
      username: ENV['INNOPAYROLL_USR'],
      password: ENV['INNOPAYROLL_PWD'],
      host: 'admsqlfin.borough.kenai.ak.us',
      database: ENV['INNOPAYROLL_DB']
    )
  end

  def call
    raise "no thumbnail for employee #{badge.employee_id}" if badge.picture.blank?

    employee_record_id = payroll_employee_record_id
    raise "cannot find employee #{badge.employee_id} in payroll employee table" if employee_record_id.blank?

    image_record_id = new_gen_id
    insert_employee_image image_record_id
    associate_employee_with_image employee_record_id, image_record_id
  end

  private

  attr_reader :badge, :client

  def associate_employee_with_image(employee_record_id, image_record_id)
    sql = "update employee set EMPLOYEEIMAGE_ID = #{image_record_id} where ID = #{employee_record_id}"
    results = client.execute(sql)
    results.do
  end

  def insert_employee_image(image_record_id)
    image_data = File.open(badge.picture.path(:thumb), 'rb').read
    image_type = badge.picture_content_type
    sql = <<-SQL
      insert into employeeimage (id, userstamp, MIMETYPE, [TIMESTAMP], image)
      select #{image_record_id}, '#{ENV['INNOPAYROLL_UPDATED_BY']}', '#{image_type}', GETDATE(), 0x#{image_data.unpack1('H*')}
    SQL
    results = client.execute(sql)
    results.do
  end

  def new_gen_id
    sql = <<-SQL
      begin transaction
        update id_gen set gen_value = gen_value + 1 where gen_key = 'currID'
        select * from id_gen where gen_key = 'currID'
      commit transaction
    SQL
    results = client.execute(sql)
    return unless results.count == 1

    results.each.first.first['GEN_VALUE'].to_i
  end

  def payroll_employee_record_id
    sql = <<-SQL
      select ID, EMPLOYEENUMBER, EMPLOYEEIMAGE_ID from EMPLOYEE where EMPLOYEENUMBER = '#{badge.employee_id}'
    SQL
    results = client.execute(sql)
    return unless results.count == 1

    results.each.first['ID'].to_i
  end
end
