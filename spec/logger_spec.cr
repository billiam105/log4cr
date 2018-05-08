require "./spec_helper"

describe Log4cr::Logger do
  describe "Acceptance" do
    it "uses a logging hierarchy" do
      buffer1 = IO::Memory.new
      buffer2 = IO::Memory.new
      buffer3 = IO::Memory.new

      appender1 = Log4cr::Appender.new buffer1
      appender2 = Log4cr::Appender.new buffer2
      appender3 = Log4cr::Appender.new buffer3

      logger1 = Log4cr::Logger.get "a.b", ::Logger::FATAL
      logger1.add_appender appender1
      logger2 = Log4cr::Logger.get "a", ::Logger::DEBUG
      logger2.add_appender appender2
      root = Log4cr::Logger.root_logger
      root.level = ::Logger::INFO
      root.add_appender appender3

      logger1.warn "A message"

      buffer1.empty?.should be_true
      buffer2.empty?.should be_false
      buffer3.empty?.should be_false
    end
  end

  describe ".root_logger" do
    Log4cr::Logger.root_logger
  end

  describe ".logger" do
    it "gets different loggers for different categories" do
      loggerA = Log4cr::Logger.get "a"
      loggerB = Log4cr::Logger.get "b"

      loggerA.should_not eq loggerB
    end

    it "gets the same logger for the same category" do
      logger1 = Log4cr::Logger.get "a"
      logger2 = Log4cr::Logger.get "a"

      logger1.level = ::Logger::WARN
      logger2.level = ::Logger::DEBUG

      logger1.level.should eq ::Logger::DEBUG
    end

    it "does not reset the level when getting the same category" do
      Log4cr::Logger.get "n", Logger::WARN
      logger = Log4cr::Logger.get "n"

      logger.level.should eq Logger::WARN
    end
  end

  describe "#info" do
    it "writes to an appender" do
      io = IO::Memory.new
      appender = Log4cr::Appender.new io
      logger = Log4cr::Logger.get "a"
      logger.add_appender appender
      logger.info "a message"

      io.empty?.should be_false
    end

    it "can write to the same appender multiple times" do
      io = IO::Memory.new
      appender = Log4cr::Appender.new io
      logger = Log4cr::Logger.get "a"
      logger.add_appender appender
      logger.add_appender appender
      logger.info "a message"

      str = io.to_s

      str.index("a message").should_not eq str.rindex("a message")
    end

    it "does NOT inherit the appenders of its children" do
      io = IO::Memory.new
      appender = Log4cr::Appender.new io
      logger = Log4cr::Logger.get "a.b"
      logger.add_appender appender
      Log4cr::Logger.get("a").info "a message"

      io.empty?.should be_true
    end

    it "logs to its parent(s)" do
      io = IO::Memory.new
      appender = Log4cr::Appender.new io
      logger = Log4cr::Logger.get "a"
      logger.add_appender appender
      Log4cr::Logger.get("a.b").info "a message"

      io.empty?.should be_false
    end

    it "can log to both itself and its parent" do
      io = IO::Memory.new
      appender = Log4cr::Appender.new io
      logger = Log4cr::Logger.get "logger"
      logger.add_appender appender
      Log4cr::Logger.root_logger.add_appender appender

      logger.info "message"
      result = io.to_s

      result.includes?("message").should be_true
      result[(result.size()/2)..-1].includes?("message").should be_true
    end

    it "does not log if the threshold is higher than info" do
      io = IO::Memory.new
      appender = Log4cr::Appender.new io
      logger = Log4cr::Logger.get "a"
      logger.add_appender appender
      logger.level = ::Logger::WARN
      logger.info "a message"

      io.empty?.should be_true
    end

    it "pervades the category all the way down" do
      io = IO::Memory.new
      appender = Log4cr::Appender.new io
      Log4cr::Logger.root_logger.add_appender appender
      Log4cr::Logger.root_logger.level = ::Logger::INFO

      Log4cr::Logger.get("category").info "some message"

      io.to_s.includes?("category").should be_true
    end

    it "can take a block to log" do
      io = IO::Memory.new
      appender = Log4cr::Appender.new io
      Log4cr::Logger.root_logger.add_appender appender

      Log4cr::Logger.get("category").info { "some message" }

      io.to_s.includes?("some message").should be_true
    end

    it "logs to the parent when the threshold allows" do
      io = IO::Memory.new
      appender = Log4cr::Appender.new io
      Log4cr::Logger.root_logger.add_appender appender
      Log4cr::Logger.root_logger.level = Logger::INFO
      Log4cr::Logger.get("category").level = Logger::WARN

      Log4cr::Logger.get("category").info { "some message" }

      message = io.to_s
      message.includes?("some message").should be_true
    end

    it "logs to the parent's appender when the threshold allows" do
      io = IO::Memory.new
      appender = Log4cr::Appender.new io
      Log4cr::Logger.root_logger.add_appender appender
      Log4cr::Logger.root_logger.level = Logger::WARN
      Log4cr::Logger.get("category").level = Logger::INFO

      Log4cr::Logger.get("category").info { "some message" }

      message = io.to_s
      message.includes?("some message").should be_true
    end

    it "doesn't double log" do
      io = IO::Memory.new
      appender = Log4cr::Appender.new io
      Log4cr::Logger.root_logger.add_appender appender
      Log4cr::Logger.root_logger.level = Logger::INFO
      Log4cr::Logger.get("category").level = Logger::INFO

      Log4cr::Logger.get("category").info { "some message" }

      message = io.to_s
      /message.+message/m.match(message).should be_nil
    end
  end
end
