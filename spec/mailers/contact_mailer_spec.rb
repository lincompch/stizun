require "spec_helper"

describe ContactMailer do


  before(:each) do
    @default_to = APP_CONFIG['default_to_email'] || 'stizun@localhost'
  end

  it "should set the right subject" do
  #  @default_to = APP_CONFIG['default_to_email'] || 'stizun@localhost'
    from = "email@example.com"
    data = {:reason => 'question', :subject => 'Foo', :body => 'Bar'}

    email = ContactMailer.send_email(from, data)
    email.from.should == [from]
    email.to.should == [@default_to]
    email.subject.should == "[Frage] Foo"
  end


end
