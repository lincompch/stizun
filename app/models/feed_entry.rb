class FeedEntry < ActiveRecord::Base
  jruby = defined?(JRUBY_VERSION)

  if jruby == false
    require 'feedzirra'
    default_scope order('published_at DESC')
    
    def self.update_from_feed(feed_url = "http://lincomp.wordpress.com/feed/")  
      feed = Feedzirra::Feed.fetch_and_parse(feed_url)  
      add_entries(feed.entries)  
    end  
    
    private  
    def self.add_entries(entries)  
      entries.each do |entry|  
        unless exists? :guid => entry.id  
          create!(  
            :title         => entry.title,  
            :content      => entry.summary,  
            :url          => entry.url,  
            :published_at => entry.published,  
            :guid         => entry.id 
          )  
        end  
      end  
    end
  end
  
end
