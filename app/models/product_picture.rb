class ProductPicture < ActiveRecord::Base
  
  
  scope :main, :conditions => { :is_main_picture => true }
  
  belongs_to :product
  
  has_attached_file :file, :styles => { :medium => ["400>x400>", :jpg], :thumb => ["80>x80>", :jpg] },
                            :convert_options => {
                                :all => "-strip"
                              }

                              
  def is_main_picture?
    is_main_picture
  end
  
  def set_main_picture
    if !product.blank?
      product.product_pictures.each do |pp|
        pp.is_main_picture = false
        pp.save
      end
    end
    self.is_main_picture = true
    self.save
  end
  
                              
end