class GtfsImportMailer < ApplicationMailer

  ADMIN_EMAIL = ENV.fetch("ADMIN_EMAIL")

  def schedule_activation_error(params={})
    @error_class = params[:error_class]
    @error_message = params[:error_message]
    @results = params[:results]
    @subject = "Schedule Activation Error"
    mail(to: ADMIN_EMAIL, subject: @subject)
  end

  def schedule_activation_success(params={})
    @results = params[:results]
    @subject = "Schedule Activation Success!"
    mail(to: ADMIN_EMAIL, subject: @subject)
  end

end
