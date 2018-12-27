class GtfsImportMailer < ApplicationMailer

  ADMIN_EMAIL = ENV.fetch("ADMIN_EMAIL")

  def schedule_activation_error(params={})
    @error_class = params[:error_class]
    @error_message = params[:error_message]
    @results = params[:results]
    mail(to: ADMIN_EMAIL, subject: "Schedule Activation Error")
  end

  def schedule_activation_success(params={})
    @results = params[:results]
    mail(to: ADMIN_EMAIL, subject: "Schedule Activation Success!")
  end

end
