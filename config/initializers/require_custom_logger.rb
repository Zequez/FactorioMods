if Rails.env.production?
  def L(*a); end
  def LL(*a); end
else
  require 'custom_logger'
  logfile = File.open("#{Rails.root}/log/custom.log", 'a')  # create log file
  logfile.sync = true  # automatically flushes data to file
  LL = CustomLogger.new(logfile)  # constant accessible anywhere

  def L(msg)
    LL.debug msg.inspect
  end

  def LN(msg)
    LL.debug msg
  end

  def LA(msg)
    LL.ap msg
  end
end
