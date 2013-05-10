class ContactMailer < ActionMailer::Base

  default :to => APP_CONFIG['default_to_email'] || 'stizun@localhost'
  default :from => APP_CONFIG['default_from_email'] || 'stizun@localhost'

  def send_email(from, data)
    @body = data[:body]
    @reason = data[:reason]
    
    if @reason == "question"
      prefix = "[Frage]"
    elsif @reason == "complaint"
      prefix = "[Reklamation]"
    else
      prefix = "[Kontakt]"
    end
  
    if data[:subject].blank?
      subject = "Kein Betreff"
    else
      subject = data[:subject]
    end

    mail(:from => from, :subject => "#{prefix} #{subject}") do |format|
      format.text
    end
  end

end
