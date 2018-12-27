# Preview all emails at http://localhost:3000/rails/mailers/gtfs_import_mailer
class GtfsImportMailerPreview < ActionMailer::Preview

  include_context "schedule report email"

  # ...?errors=true
  # ...?activation=true
  def schedule_report
    #message_options = if params[:errors]
    #  { results: error_results }
    #elsif params[:activation]
    #  { results: activation_results }
    #else
    #  { results: verification_results }
    #end
    message_options = { results: activation_results }

    GtfsImportMailer.schedule_report(message_options).deliver_now
  end

  private

  #def error_results
  #  blank_results.merge(errors: [ { class: "MyError", message: "Oh, something went wrong" } ])
  #end

  def activation_results
    blank_results.merge(new_schedule_activation: true, hostd_schedule: hosted_schedule, active_schedule: active_schedule)
  end

  #def verification_results
  #  blank_results.merge(new_schedule_activation: false)
  #end

  def blank_results
    {
      source_url: "http://www.my-site.com/gtfs-feed.zip",
      destructive: false,
      start_at: (DateTime.now - 3.minutes).to_s,
      end_at: DateTime.now.to_s
    }
  end

  def hosted_schedule
    {
      "id"=>3,
      "source_url"=>"http://www.shorelineeast.com/google_transit.zip",
      "published_at"=>"________",
      "content_length"=>12375,
      "etag"=>"9876-919fh430wmsl",
      "active"=>true,
      "created_at"=>"_____",
      "updated_at"=>""
    }
  end

  def active_schedule
    {
      "id"=>2,
      "source_url"=>"http://www.shorelineeast.com/google_transit.zip",
      "published_at"=>"________",
      "content_length"=>12375,
      "etag"=>"1234-56abcdef78khkpw",
      "active"=>false,
      "created_at"=>"_____",
      "updated_at"=>""
    }
  end

end
