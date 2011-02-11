class ImageHandler

  # Retrieves an image by HTTP if its url exists. Saves it as
  # /tmp/id.extname
  def self.get_image_by_http(url, id)
    # TODO, in pseudocode
    # require http lib
    # retrieve file

    begin
      open(url) do |input|
        file_path = Rails.root + "tmp/downloads/#{id}#{File.extname(url)}"
        if ["image/gif", "image/png", "image/jpeg"].include?(input.content_type)

          if File.exists?(file_path)
            return file_path
          else
            file = File.open(file_path, 'w') do |output|
                output << input.read
            end
            return file.path
          end
          
        end
      end
      
    rescue
      puts "Couldn't retrieve image #{url} due to a network error or 404"
      return nil
    end
  end

end