# app/mailers/application_mailer.rb
class ApplicationMailer < ActionMailer::Base
  default from: 'ARIAGUMA GROUP<contact@ariaguma.jp>'
  layout "mailer"
end
