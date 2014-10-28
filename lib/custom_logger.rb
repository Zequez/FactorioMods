class CustomLogger < Logger
  def initialize(file)
    super
  end

  def format_message(severity, timestamp, progname, msg)
    msg + "\n"
  end

  def debug(msg)
    super msg.inspect
  end
end

logfile = File.open("#{Rails.root}/log/custom.log", 'a')  # create log file
logfile.sync = true  # automatically flushes data to file
LL = CustomLogger.new(logfile)  # constant accessible anywhere

def L(msg)
  LL.debug msg
end