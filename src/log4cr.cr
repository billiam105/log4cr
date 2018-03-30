require "./log4cr/*"

# TODO: Write documentation for `Log4cr`
module Log4cr
  alias Appender = ::Logger

  class Logger
    private class_getter repo = LoggerRepository.new
    private getter appenders = Array(Appender).new
    private getter parent : Logger
    property level : ::Logger::Severity

    def initialize(@parent)
      @level = ::Logger::INFO
    end

    def self.root_logger
      repo.get ""
    end

    def self.get(category : String) : Logger
      repo.get category
    end

    def add_appender(appender : Appender)
      appenders << appender
    end

    {% for threshold in %i(debug info warn error fatal) %}
      def {{threshold.id}}(message : String)
        if level < ::Logger::{{threshold.id.upcase}}
          appenders.each do |appender|
            appender.{{threshold.id}} message
          end
        end
        parent.{{threshold.id}} message
      end
    {% end %}
  end

  class RootLogger < Logger
    def initialize
      super self
    end

    {% for threshold in %i(debug info warn error fatal) %}
      def {{threshold.id}}(message : String)
        if level < ::Logger::{{threshold.id.upcase}}
          appenders.each do |appender|
            appender.{{threshold.id}} message
          end
        end
      end
    {% end %}
  end

  class LoggerRepository
    private getter repo = Hash(String, Logger).new

    def initialize
      repo[""] = RootLogger.new
    end

    def get(category : String) : Logger
      unless repo.has_key? category
        parent = parent_category category
        repo[category] = Logger.new get parent
      end
      repo[category]
    end

    def parent_category(category : String) : String
      unless category.includes? "."
        ""
      else
        category[0...(category.rindex ".").as Int32]
      end
    end
  end
end
