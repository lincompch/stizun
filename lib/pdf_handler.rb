require 'file_downloader'

class PdfHandler
  
  # Retrieves an image by HTTP if its url exists. Saves it as
  # /tmp/id.extname
  def self.get_pdf_by_http(url, id)
    fdl = FileDownloader.new
    fdl.accepted_content_types = ['application/pdf']
    file_path = Rails.root + "tmp/downloads/#{id}_#{File.basename(url)}"
    return fdl.by_http(url, file_path)
  end

end