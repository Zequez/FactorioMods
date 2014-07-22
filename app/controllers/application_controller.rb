class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def not_found
    render 'errors/404', status: 404
  end

  def access_denied(exception = nil)
    render text: '403 Access denied', status: 403
  end
end
