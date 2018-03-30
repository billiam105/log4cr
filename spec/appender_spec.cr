require "./spec_helper"

describe Log4cr::Appender do
  it "is a logger" do
    appender = Log4cr::Appender.new STDOUT

    appender.should be_a ::Logger
  end
end
