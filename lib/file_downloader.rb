class FileDownloader
  
  attr_accessor :accepted_content_types
  
  # Options: 
  #    accepted_content_types: array of strings representing the content types
  #                            we'd like to download. e.g.: ['text/html', 'image/jpeg']
  def initialize(options = {})
    unless options.blank?
      unless options[:accepted_content_types].blank?
        @accepted_content_types = options[:accepted_content_types]
      else
        @accepted_content_types = ['text/html']
      end
    end
  end
  
  # Gets a file and downloads it to a destination directory
  def by_http(url, destination_path)
    begin
      open(url) do |input|
        if @accepted_content_types.include?(input.content_type)

          if File.exists?(destination_path)
            return destination_path
          else
            file = File.open(destination_path, 'wb') do |output|
                output << input.read
            end
            return file.path
          end
        else
          # need to send this to the logger at some point
          #logger.error "Content type for #{url} not accepted by this downloader instance."
          puts "[FileDownloader] Content type for #{url} not accepted by this downloader instance."
          return nil
        end
      end
      rescue Errno::ENOENT
        puts "[FileDownloader] Can't open file for writing"
        return nil
      rescue Exception => e
       puts "[FileDownloader] Couldn't retrieve file #{url} due to an error: #{e.to_s}"
       return nil
    end
  end
  
  
end