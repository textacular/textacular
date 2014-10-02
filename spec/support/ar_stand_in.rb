class ARStandIn < ActiveRecord::Base;
  self.abstract_class = true
  extend Textacular
end
