require "./spec_helper"

describe Log4cr::Appender do
  it "is a logger" do
    appender = Log4cr::Appender.new STDOUT

    appender.should be_a ::Logger
  end

  it "is 'always on'" do
    appender = Log4cr::Appender.new STDOUT

    appender.level.should eq ::Logger::DEBUG
  end
end
