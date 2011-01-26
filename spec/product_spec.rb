require 'spec_helper'

describe Product do
  describe "componentized product" do
    it "should have some supply items" do
      create_supplier("Alltron AG")
      create_supply_items.count.should > 0
    end
  end
end