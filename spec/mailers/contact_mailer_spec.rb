#encoding: utf-8
require "spec_helper"

describe ContactMailer do


  before(:all) do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
  end

  before(:each) do
    @default_to = APP_CONFIG['default_to_email'] || 'stizun@localhost'
    @from = "email@example.com"
  end

  it "should set the right subject" do
    data = {:reason => 'question', :subject => 'Foo', :body => 'Bar'}

    email = ContactMailer.send_email(@from, data).deliver
    email.from.should == [@from]
    email.to.should == [@default_to]
    email.subject.should == "[Frage] Foo"
    ActionMailer::Base.deliveries.size.should == 1
  end

  it "should set 'Kein Betreff' if no subject was given" do
    data = {:subject => nil, :body => 'Foo'}
    email = ContactMailer.send_email(@from, data).deliver
    email.subject.should == "[Kontakt] Kein Betreff"
    ActionMailer::Base.deliveries.size.should == 1
  end

  it "should set a default prefix of '[Kontakt]' if none was selected" do
    data = {:reason => 'unknown', :subject => 'Something', :body => 'Foo'}
    email = ContactMailer.send_email(@from, data).deliver
    email.subject.should == "[Kontakt] Something"
    ActionMailer::Base.deliveries.size.should == 1
  end

  it "should include the right text in the message" do
    data = {:body => 'Foo'}
    email = ContactMailer.send_email(@from, data).deliver
    email.body.to_s.should == "Liebe Lincomp\n\nIch habe folgendes Anliegen:\n\nFoo\n\nDanke für die Beantwortung und freundliche Grüsse\n"
    ActionMailer::Base.deliveries.size.should == 1
  end


end
