require "logger"
require "./log4cr/*"

# TODO: Write documentation for `Log4cr`
module Log4cr
  class Appender < ::Logger
    def initialize(io : IO?)
      super io
      @level = ::Logger::DEBUG
    end
  end

  class Logger
    private class_getter repo = LoggerRepository.new
    protected getter appenders = Array(Appender).new
    private getter parent : Logger
    private getter category : String
    property level : ::Logger::Severity

    def initialize(@parent, @category, @level = ::Logger::INFO)
    end

    def self.root_logger
      repo.get ""
    end

    def self.get(category : String, level = ::Logger::INFO) : Logger
      repo.get category, level
    end

    def add_appender(appender : Appender)
      appenders << appender
    end

    def all_appenders
      appenders + parent.all_appenders
    end

    {% for threshold in %i(debug info warn error fatal) %}
      def {{threshold.id}}(message : String)
        {{threshold.id}} message, category
      end

      def {{threshold.id}}(&block)
        if any_{{threshold.id}}?
          message = yield.to_s
          {{threshold.id}} message, category
        end
      end

      protected def any_{{threshold.id}}?
        if parent == self
          {{threshold.id}}?
        else
          {{threshold.id}}? || parent.any_{{threshold.id}}?
        end
      end

      protected def {{threshold.id}}(message : String, child_category)
        if !message.empty? && {{threshold.id}}?
          all_appenders.each do |appender|
            appender.{{threshold.id}} message, child_category
          end
        else
          parent.{{threshold.id}} message, child_category unless parent == self
        end
      end

      def {{threshold.id}}?
        level <= ::Logger::{{threshold.id.upcase}}
      end
    {% end %}
  end

  class RootLogger < Logger
    def initialize
      super self, "root"
    end

    def all_appenders
      appenders
    end
  end

  class LoggerRepository
    protected getter repo = Hash(String, Logger).new

    def initialize
      repo[""] = RootLogger.new
    end

    def get(category : String, threshold = ::Logger::INFO) : Logger
      unless repo.has_key? category
        parent = parent_category category
        repo[category] = Logger.new get(parent), category, threshold
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
