if Rails.env.development? or true
  require 'custom_logger'
else
  def L(*a); end
end