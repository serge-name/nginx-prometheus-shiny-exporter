class MyLog

  @prefix : String
  @io     : IO

  def initialize(prefix : String, debug = false)
    @prefix = prefix
    @debug = debug
    @io = STDERR
  end

  def info(message : String) : Nil
    @io.puts("#{stamp}#{@prefix}: INFO: #{message}")
  end

  def debug(message : String) : Nil
    @io.puts("#{stamp}#{@prefix}: DEBUG: #{message}") if @debug
  end

  def error(message : String) : Nil
    @io.puts("#{stamp}#{@prefix}: ERROR: #{message}")
  end

  private def stamp : String
    @io.tty? ? Time.now.to_s("%FT%X%z ") : ""
  end

end
