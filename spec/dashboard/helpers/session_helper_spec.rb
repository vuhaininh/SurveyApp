require 'spec_helper'

RSpec.describe "Svipk::Dashboard::SessionHelper" do
  pending "add some examples to (or delete) #{__FILE__}" do
    let(:helpers){ Class.new }
    before { helpers.extend Svipk::Dashboard::SessionHelper }
    subject { helpers }

    it "should return nil" do
      expect(subject.foo).to be_nil
    end
  end
end
