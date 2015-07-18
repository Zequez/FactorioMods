if Rails.env.production?
  def L(*a); end
else
  require 'custom_logger'
  logfile = File.open("#{Rails.root}/log/custom.log", 'a')  # create log file
  logfile.sync = true  # automatically flushes data to file
  LL = CustomLogger.new(logfile)  # constant accessible anywhere

  def L(msg)
    LL.debug msg
  end
end