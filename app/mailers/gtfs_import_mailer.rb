class GtfsImportMailer < ApplicationMailer

  ADMIN_EMAIL = "someone@example.com"

  def schedule_activation_error(params={})
    @results = params[:results]
    @error_class = params[:error_class]
    @error_message = params[:error_message]
    mail(to: ADMIN_EMAIL, subject: "Schedule Activation Error")
  end

  #def schedule_activation_success
  #  @results = params[:results]
  #  mail(to: ADMIN_EMAIL, subject: "Schedule Activation Error")
  #end

end
