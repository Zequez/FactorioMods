require 'custom_logger'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from CanCan::AccessDenied, with: :authentication_error
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActionController::ParameterMissing, with: :wrong_parameters_error

  before_action :configure_devise_permitted_parameters, if: :devise_controller?

  before_action do
    L request.subdomain
  end

  # Ignore JSON requests by default
  # (Rails 4.1 tries to serve them by default)
  respond_to :html

  def not_found
    params[:controller] = 'errors'
    params[:action] = 'error-404'
    @error_code = 404
    render 'errors/base', status: 404
  end

  def access_denied(exception = nil)
    params[:controller] = 'errors'
    params[:action] = 'error-403'
    @error_code = 403
    render 'errors/base', status: 403
  end

  def authentication_error(exception = nil)
    params[:controller] = 'errors'
    params[:action] = 'error-401'
    if request.get? and not current_user
      # Turbolinks redirection doesn't change the referer for the next page
      redirect_to new_user_session_path(redirect_to: request.path),
         flash: { alert: I18n.t('devise.failure.unauthenticated') }
    else
      @error_code = 401
      render 'errors/base', status: 401
    end
  end

  def wrong_parameters_error(exception = nil)
    render text: '', status: 400
  end

  def configure_devise_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up).push(:name, :email)
    devise_parameter_sanitizer.for(:sign_in).push(:login)
    devise_parameter_sanitizer.for(:account_update)
  end

  def after_sign_in_path_for(resource)
    begin
      params[:redirect_to] ? URI(params[:redirect_to]).path : super
    rescue URI::InvalidURIError => e
      super
    end
  end
end
