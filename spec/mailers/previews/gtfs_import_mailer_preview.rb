# Preview all emails at http://localhost:3000/rails/mailers/gtfs_import_mailer
class GtfsImportMailerPreview < ActionMailer::Preview

  def schedule_activation_error
    message_options = {
      error_class: "MyError",
      error_message: "OOPS, something unexpected happened.",
      results: {}
    }
    GtfsImportMailer.schedule_activation_error(message_options).deliver_now
  end

end
