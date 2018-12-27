RSpec.shared_context "schedule report email" do

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
