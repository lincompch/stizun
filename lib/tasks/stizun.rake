namespace :stizun do
   
   desc "Add all new Feed entries"
   task :update_feed => :environment do
      FeedEntry.update_from_feed
      puts "Feed entries were added"
   end
end
