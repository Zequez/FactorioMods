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