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

   desc "Update categories ancestry"
   task :update_categories_ancestry => :environment do
    # just need to save category, which will trigger after_save callback
     pb = ProgressBar.new("Updating categories ancestry", Category.count)
     Category.all.each { |category| category.save!; pb.inc }
     pb.finish
   end
end

