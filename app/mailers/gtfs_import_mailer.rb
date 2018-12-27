class GtfsImportMailer < ApplicationMailer

  ADMIN_EMAIL = ENV.fetch("ADMIN_EMAIL")

  def results_report(params={})
    @results = params[:results]

    @subject = if results[:errors].any?
      "Schedule Import Failure"
    elsif
      "Schedule Activation!"
    else
      "Schedule Activation!"
    end

    mail(to: ADMIN_EMAIL, subject: @subject)
  end

end
