# Preview all emails at http://localhost:3000/rails/mailers/gtfs_import_mailer
class GtfsImportMailerPreview < ActionMailer::Preview

  # need to upgrade to rails 5.2 to use request params in mailers...
  ## ...?errors=true
  ## ...?activation=true
  #def schedule_report(params={})
  #  #message_options = if params[:errors]
  #  #  { results: error_results }
  #  #elsif params[:activation]
  #  #  { results: activation_results }
  #  #else
  #  #  { results: verification_results }
  #  #end
  #  message_options = { results: activation_results }
  #  GtfsImportMailer.schedule_report(message_options).deliver_now
  #end

  def schedule_activation_report
    message_options = { results: activation_results }
    GtfsImportMailer.schedule_report(message_options).deliver_now
  end

  def schedule_verification_report
    message_options = { results: verification_results }
    GtfsImportMailer.schedule_report(message_options).deliver_now
  end

    def schedule_failure_report
    message_options = { results: error_results }
    GtfsImportMailer.schedule_report(message_options).deliver_now
  end

  private

  def error_results
    blank_results.merge(
      end_at: "",
      errors: [ { class: "MyError", message: "Oh, something went wrong" } ]
    )
  end

  def activation_results
    blank_results.merge(
      hosted_schedule: hosted_schedule,
      schedule_activation: true
    )
  end

  def verification_results
    blank_results.merge(
      hosted_schedule: hosted_schedule,
      schedule_verification: true
    )
  end

  def blank_results
    start_at = (Time.zone.now - 3.minutes)
    end_at = Time.zone.now
    duration_seconds = end_at - start_at
    puts "SECONDS:\n"
    puts duration_seconds
    duration_readable = Time.at(duration_seconds).utc.strftime("%H:%M:%S")
    puts "READABLE:\n"
    puts duration_readable
    {
      source_url: "http://www.my-site.com/gtfs-feed.zip",
      destructive: false,
      start_at: start_at.to_s,
      end_at: end_at.to_s,
      duration_seconds: duration_seconds,
      duration_readable: duration_readable
    }
  end

  def hosted_schedule
    {
      id: 3,
      source_url: "http://www.my-site.com/gtfs-feed.zip",
      published_at: "2017-03-30 13:54:24 -0400",
      content_length: 6921,
      etag: "9876-919fh430wmsl",
      active: true,
      #created_at: "2017-05-21 15:12:42 -0400",
      #updated_at: "2017-05-21 15:13:00 -0400"
    }
  end


end
