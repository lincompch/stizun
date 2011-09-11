require 'spec_helper'

describe FeedEntry do
  before(:all) do
    @file = File.join("file://",Rails.root, "test", "fixtures", "feed.rss")
    FeedEntry.count.should == 0
  end

  it 'should add new entries if they didnt exist' do
    FeedEntry.update_from_feed(@file)
    FeedEntry.count.should == 6
  end

  it 'should not add existing entries' do
    FeedEntry.update_from_feed(@file)
    FeedEntry.count.should == 6
    FeedEntry.update_from_feed(@file)
    FeedEntry.count.should == 6
  end

end

