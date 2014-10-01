require 'support/ar_stand_in'
require 'support/not_there'

RSpec.describe Textacular do
  context "after extending ActiveRecord::Base" do
    it "doesn't break #respond_to?" do
      expect{ ARStandIn.respond_to?(:abstract_class?) }.to_not raise_error
    end

    it "doesn't break #respond_to? for table-less classes" do
      expect(NotThere.table_exists?).to be_falsey
      expect { NotThere.respond_to? :system }.to_not raise_error
    end
  end
end
