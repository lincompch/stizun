namespace :stizun do
   
   desc "Add all new Feed entries"
   task :update_feed => :environment do
      FeedEntry.update_from_feed
      puts "Feed entries were added"
   end
   
   desc "Add all new Feed entries"
   task :deliver_notification_emails => :environment do
      Notification.deliver_emails
      puts "Emails sent"
   end
end
