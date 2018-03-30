require "./spec_helper"

describe Log4cr::Logger do
  describe "Acceptance" do
    it "uses a logging hierarchy" do
      buffer1 = IO::Memory.new
      buffer2 = IO::Memory.new
      buffer3 = IO::Memory.new

      appender1 = Log4cr::Appender.new buffer1
      appender1.level = ::Logger::INFO
      appender2 = Log4cr::Appender.new buffer2
      appender2.level = ::Logger::ERROR
      appender3 = Log4cr::Appender.new buffer3
      appender3.level = ::Logger::DEBUG

      logger1 = Log4cr::Logger.get "a.b"
      logger1.level = ::Logger::FATAL
      logger1.add_appender appender1
      logger2 = Log4cr::Logger.get "a"
      logger2.level = ::Logger::DEBUG
      logger2.add_appender appender2
      root = Log4cr::Logger.root_logger
      root.level = ::Logger::DEBUG
      root.add_appender appender3

      logger1.warn "A message"

      buffer1.empty?.should be_true
      buffer2.empty?.should be_true
      buffer3.empty?.should be_false
    end
  end

  describe ".root_logger" do
    Log4cr::Logger.root_logger
  end
end
