if Rails.env.development?
  require 'custom_logger'
else
  def L(*a); end
end