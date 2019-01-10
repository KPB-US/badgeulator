class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: exception.message
  end

  rescue_from Net::LDAP::Error do |exception|
    redirect_to new_user_session_url, alert: "LDAP Error - #{exception.message}"
  end
end
