require 'support/ar_stand_in'

RSpec.describe Textacular do
  context "after extending ActiveRecord::Base" do
    it "doesn't break #respond_to?" do
      expect{ ARStandIn.respond_to?(:abstract_class?) }.to_not raise_error
    end
  end
end
