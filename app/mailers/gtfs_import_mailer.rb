class GtfsImportMailer < ApplicationMailer

  ADMIN_EMAIL = ENV.fetch("ADMIN_EMAIL")

  def schedule_report(params={})
    @results = params[:results]
    raise "Expecting results" unless @results && @results.is_a?(Hash)
    @source_url = @results[:source_url]
    @hosted_schedule = @results[:hosted_schedule]
    @schedule_activation = @results[:schedule_activation] == true
    @schedule_verification = @results[:schedule_verification] == true
    @errors = @results[:errors]

    @subject = if @errors
      "GTFS Schedule Processing Failure"
    elsif @schedule_activation == true
      "GTFS Schedule Activation!"
    elsif @schedule_verification == true
      "GTFS Schedule Verification"
    else
      raise "GTFS IMPORT EMAIL SUBJECT COMPILATION FAILURE"
    end

    mail(to: ADMIN_EMAIL, subject: @subject)
  end

end
