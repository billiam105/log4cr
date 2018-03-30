require "./log4cr/*"

# TODO: Write documentation for `Log4cr`
module Log4cr
  alias Appender = ::Logger

  class Logger
    def self.root_logger
      RootLogger.new
    end

    def self.get(category)
      Logger.new
    end

    def level=(level)
    end

    def add_appender(appender)
    end

    def warn(message)
    end
  end

  class RootLogger < Logger
  end

  class LoggerRepository
    def get(category)
      RootLogger.new
    end
  end
end
