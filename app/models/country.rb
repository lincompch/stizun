class Country < ActiveRecord::Base
  has_many :addresses
  
  def to_s
    return name
  end
end
