require "./spec_helper"

describe Log4cr::LoggerRepository do
  describe "#get" do
    it "gets a RootLogger from an empty category" do
      repo = Log4cr::LoggerRepository.new

      logger = repo.get ""

      logger.should be_a Log4cr::RootLogger
    end

    it "gets a Logger from a non-empty category" do
      repo = Log4cr::LoggerRepository.new

      logger = repo.get "a"

      logger.should be_a Log4cr::Logger
      logger.should_not be_a Log4cr::RootLogger
    end
  end

  describe "#parent_category" do
    it "is empty when the category is empty" do
      repo = Log4cr::LoggerRepository.new

      parent = repo.parent_category ""

      parent.should eq ""
    end

    it "is empty when the category has no '.'" do
      repo = Log4cr::LoggerRepository.new

      parent = repo.parent_category "name"

      parent.should eq ""
    end

    it "is everything through the last '.'" do
      repo = Log4cr::LoggerRepository.new

      parent = repo.parent_category "a.b.c"

      parent.should eq "a.b"
    end
  end
end
