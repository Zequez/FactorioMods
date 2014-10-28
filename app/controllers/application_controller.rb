class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from CanCan::AccessDenied, with: :authentication_error

  def not_found
    render 'errors/404', status: 404
  end

  def access_denied(exception = nil)
    render text: '403 Access denied', status: 403
  end

  def authentication_error(exception = nil)
    render text: '401 Authentication error, you need to log in', status: 401
  end

  ### Helpers
  ###############

  def mod_path(mod)
    polymorphic_path([mod.category, mod])
  end
  helper_method :mod_path
end
