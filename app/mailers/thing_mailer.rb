class ThingMailer < ActionMailer::Base
  default from: "tbtitw@gunnertech.com"
  
  def notification_email(thing)
    @thing = thing
    mail(to: "tbtitw@gunnertech.com", bcc: User.where{ send_new_thing_notification == true }.select(:email).map(&:email), :subject => "Thing Added!")
  end
end
