class GtfsImportMailer < ApplicationMailer

  ADMIN_EMAIL = ENV.fetch("ADMIN_EMAIL")

  def schedule_report(params={})
    @results = params[:results]
    validate_results
    @source_url = @results[:source_url]
    @start_at = @results[:start_at]
    @end_at = @results[:end_at]
    #@duration_seconds = @results[:duration_seconds]
    @duration_readable = @results[:duration_readable]
    @hosted_schedule = @results[:hosted_schedule]
    @schedule_activation = @results[:schedule_activation]
    @schedule_verification = @results[:schedule_verification]
    @errors = @results[:errors]

    @subject = if @schedule_activation == true
      "GTFS Schedule Activation!"
    elsif @schedule_verification == true
      "GTFS Schedule Verification"
    elsif @errors.any?
      "GTFS Schedule Processing Failure"
    else
      raise "GTFS IMPORT EMAIL SUBJECT COMPILATION FAILURE"
    end

    mail(to: ADMIN_EMAIL, subject: @subject)
  end

  private

  def validate_results
    raise "Expecting results" unless @results && @results.is_a?(Hash)
  end

end
