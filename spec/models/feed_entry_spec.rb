require 'spec_helper'

describe FeedEntry do
  before(:all) do
    @file = File.join("file://",Rails.root, "test", "fixtures", "feed.rss")
  end
  
  it 'should add new entries if they didnt exist' do
    expect {FeedEntry.update_from_feed(@file)}.to change (FeedEntry, :count).by(6)
  end
  
  it 'should not add existing entries' do
    expect {FeedEntry.update_from_feed(@file)}.to change (FeedEntry, :count).by(6)
    
    expect {FeedEntry.update_from_feed(@file)}.to change (FeedEntry, :count).by(0)
  end
  
end
