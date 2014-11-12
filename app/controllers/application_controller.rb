require 'custom_logger'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from CanCan::AccessDenied, with: :authentication_error
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

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
    @error_code = 401
    render 'errors/base', status: 401
  end

  ### Helpers
  ###############

  def mod_path(mod, options = {})
    polymorphic_path([mod.category, mod], options)
  end
  helper_method :mod_path
end
