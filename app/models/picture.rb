class Picture << ActiveRecord::Base
  
  has_attached_file :file, :styles => { :medium => ["300x300>", :jpg], :thumb => ["80x80>", :jpg] },
                           :convert_options => {
                               :all => "-strip"
                             }

end