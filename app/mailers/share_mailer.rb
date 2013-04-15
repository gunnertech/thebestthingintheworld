class ShareMailer < ActionMailer::Base
  default from: "tbtitw@gunnertech.com"
  
  def matchup_email(user,thing_1,thing_2,email_addresses)
    @user = user
    @thing_1 = thing_1
    @thing_2 = thing_2
    @url = user_assigned_things_comparision_url("me", first_thing_id: thing_1.try(:id), second_thing_id: thing_2.try(:id))
    @email_addresses = email_addresses.split("\r\n").uniq.flatten.reject{|email| !(email =~ /^[a-zA-Z][\w\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$/) }
    
    mail(from: user.email, bcc: @email_addresses, subject: "#{user.name} sent you a matchup!")
  end
end
