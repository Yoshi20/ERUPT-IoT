class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_locale
  before_action :authenticate_user!, except: [:index, :show, :location, :unregistered]
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :prepare_exception_notifier

  protected

  def configure_permitted_parameters
    #new
    added_attrs = [:username, :email, :password, :password_confirmation, :remember_me, :full_name, :mobile_number]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  end

  def after_sign_in_path_for(resource)
    if request.referer.nil? or request.referer.include?('/users/')
     root_path
    else
     request.referer
    end
  end

  def after_sign_out_path_for(resource)
    root_path
  end

private

  def set_locale
    if params[:locale].present?
      cookies.permanent[:locale] = params[:locale]
    end
    localeCookie = cookies[:locale]
    if localeCookie.present?
      I18n.locale = localeCookie
    else
      I18n.locale = http_accept_language.compatible_language_from(I18n.available_locales)
      cookies.permanent[:locale] = I18n.locale.to_s
    end
  end

  def prepare_exception_notifier
    request.env["exception_notifier.exception_data"] = {
      current_user: current_user
    }
  end

end
