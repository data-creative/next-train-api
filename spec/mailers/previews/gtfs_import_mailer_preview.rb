# Preview all emails at http://localhost:3000/rails/mailers/gtfs_import_mailer
class GtfsImportMailerPreview < ActionMailer::Preview

  def schedule_activation_error
    my_error = { class: "MyError", message: "OOPS, something unexpected happened." }
    message_options = {
      error_class: my_error[:class],
      error_message: my_error[:message],
      results: mock_results.merge(:errors=>[my_error])
    }
    GtfsImportMailer.schedule_activation_error(message_options).deliver_now
  end

  def schedule_activation_success
    message_options = { results: mock_results }
    GtfsImportMailer.schedule_activation_success(message_options).deliver_now
  end

  private

  def mock_results
    {
      :source_url=>"http://www.my-site.com/gtfs-feed.zip",
      :destination_path=>"./tmp/google_transit.zip",
      :destructive_mode=>false,
      :started_at=>DateTime.now.to_s,
      :ended_at=>"",
      :hosted_schedule=> {a:1, b:2},
      :errors=>[]
    }
  end

end
