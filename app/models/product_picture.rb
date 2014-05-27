class ProductPicture < ActiveRecord::Base
  scope :main, -> { where(:is_main_picture => true) }

  belongs_to :product

  mount_uploader :file, ProductPictureUploader, :mount_on => :file_file_name

#   has_attached_file :file,  :styles => { :medium => ["400>x400>", :jpg],
#                                          :thumb => ["80x80>", :jpg] },
#                             :convert_options => {
#                                          :all => "-limit memory 10485760 -limit map 20971520 -strip -background white -flatten"
#                                        }

  def is_main_picture?
    is_main_picture
  end

  def set_main_picture
    product.product_pictures.each do |pp|
      pp.is_main_picture = false
      pp.save
    end if !product.blank?

    self.is_main_picture = true
    self.save
  end


end

