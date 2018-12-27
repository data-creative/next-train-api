# Preview all emails at http://localhost:3000/rails/mailers/gtfs_import_mailer
class GtfsImportMailerPreview < ActionMailer::Preview

  # ...?errors=true
  # ...?activation=true
  def schedule_report
    if params[:errors] == true
      puts "ERRORS!"
    end

    message_options = if params[:errors]
      { results: error_results }
    elsif params[:activation]
      { results: activation_results }
    else
      { results: verification_results }
    end

    GtfsImportMailer.schedule_report(message_options).deliver_now
  end

  private

  def error_results
    blank_results.merge(errors: [ { class: "MyError", message: "Oh, something went wrong" } ])
  end

  def activation_results
    blank_results.merge(new_schedule_activation: true)
  end

  def verification_results
    blank_results.merge(new_schedule_activation: false)
  end

  def blank_results
    {
      source_url: "http://www.my-site.com/gtfs-feed.zip",
      destructive: false,
      start_at: (DateTime.now - 3.minutes).to_s,
      end_at: DateTime.now.to_s
    }
  end

end
