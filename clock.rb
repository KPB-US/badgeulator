require 'clockwork'
require './config/boot'
require './config/environment'

module Clockwork
  configure do |config|
    config[:sleep_timeout] = 15
    config[:logger] = Logger.new(File.join(Rails.root, 'log', 'clockwork.log'))

    ENV['USE_LDAP'] = 'true' # cant update thumbnails without it
  end

  handler do |job|
    puts "Running #{job}"
  end

  # handler receives the time when job is prepared to run in the 2nd argument
  # handler do |job, time|
  #   puts "Running #{job}, at #{time}"
  # end

  every(4.hours, 'Badge.update_missing_dns') do
    Badge.update_missing_dns
  end
end
