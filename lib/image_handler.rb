require 'file_downloader'

class ImageHandler
  
  # Retrieves an image by HTTP if its url exists. Saves it as
  # /tmp/id.extname
  def self.get_image_by_http(url, id)
    fdl = FileDownloader.new
    fdl.accepted_content_types = ['image/gif', 'image/png', 'image/jpeg']
    file_path = Rails.root + "tmp/downloads/#{id}_#{File.basename(url)}"
    return fdl.by_http(url, file_path)
  end

end