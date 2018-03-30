require "./spec_helper"

describe Log4cr::LoggerRepository do
  describe "#get" do
    it "gets a RootLogger from an empty category" do
      repo = Log4cr::LoggerRepository.new

      logger = repo.get ""

      logger.should be_a Log4cr::RootLogger
    end
  end
end
