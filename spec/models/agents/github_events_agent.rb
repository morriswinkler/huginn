require 'spec_helper'

describe Agents::GithubEvents do
  
  before do
    @checker = Agents::GithubEvents.new(:user => "cantino", :expecting_ipdate_period_in_days => "2")
    @checker.user = users(:jane)
    @checker.save!
  end
  
  describe "#check" do
    it "should check that initial run creates an event" do
      expect { @checker.check }.to change { Event.count }.by(1)
    end
  end
  
  describe "#working?" do
    it "checks if its generating events as scheduled" do
      @checker.should_not be_working
      @checker.check
      @checker.reload.should be_working
      three_days_from_now = 3.days.from_now
      stub(Time).now { three_days_from_now }
      @checker.should_not be_working
    end
  end
end
