class ProductPicture < ActiveRecord::Base
  
  
  scope :main, :conditions => { :is_main_picture => true }
  
  belongs_to :product
  
  has_attached_file :file, :styles => { :medium => ["400x400>", :jpg], :thumb => ["80x80>", :jpg] },
                            :convert_options => {
                                :all => "-strip"
                              }

  def is_main_picture?
    is_main_picture
  end
                              
end