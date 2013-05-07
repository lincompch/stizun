class ContactMailer < ActionMailer::Base

  default :to => APP_CONFIG['default_to_email'] || 'stizun@localhost'
  default :from => APP_CONFIG['default_from_email'] || 'stizun@localhost'

  def send_email(from, data)
    if data[:reason] == "question"
      prefix = "[Frage]"
    else
      prefix = "[Kontakt]"
    end

    mail(:from => from, :subject => "#{prefix} #{data[:subject]}", :body => data[:body])
  end

end
