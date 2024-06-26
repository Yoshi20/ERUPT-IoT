class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  rescue_from ActionController::InvalidAuthenticityToken do |ex|
    redirect_to new_user_session_path, alert: t('flash.alert.login_failed')
  end

  before_action :set_locale
  before_action :authenticate_user!, except: [:index, :show]
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

  def after_sign_in_path_for(resource_or_scope)
    time_stamps_path
  end

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

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

  def authenticate_admin!
    unless current_user.present? && current_user.admin?
      render_forbidden
      return
    end
  end

  def render_forbidden
    respond_to do |format|
      format.html { redirect_to root_path, alert: t('flash.alert.unauthorized') }
      format.json { render json: { status: 'error', message: t('flash.alert.unauthorized') }, status: :forbidden }
    end
  end

end
