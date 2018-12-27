class GtfsImportMailer < ApplicationMailer

  ADMIN_EMAIL = ENV.fetch("ADMIN_EMAIL")

  def schedule_report(params={})
    @results = params[:results]
    @active_schedule = @results.try(:active_schedule)
    @hosted_schedule = @results.try(:hosted_schedule)
    @new_schedule_activation = @results.try(:new_schedule_activation) == true
    @errors = @results.try(:errors)

    @subject = if @errors
      "GTFS Schedule Error(s)"
    elsif @new_schedule_activation == true
      "GTFS Schedule Activation!"
    elsif @results
      "GTFS Schedule Verification"
    else
      "GTFS Importer Email"
    end

    mail(to: ADMIN_EMAIL, subject: @subject)
  end

end
