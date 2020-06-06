class ProductSet < ActiveRecord::Base
  belongs_to :component, :class_name => "SupplyItem"
  belongs_to :product

  validates_inclusion_of :quantity, :in => 1..100, :message => "must be between 1 and 100"

  def purchase_price
    self.quantity * self.component.purchase_price
  end

  def weight
    self.quantity * self.component.weight
  end

  def cleanup
    ProductSet.all.each do |ps|
      ps.delete if ps.component.nil?
    end
  end

end