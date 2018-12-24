class ApplicationMailer < ActionMailer::Base
  default from: "application-mailer@#{ENV['MAILER_HOST']}"
  layout 'mailer'
end
