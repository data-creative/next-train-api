RSpec.shared_context "schedule report email" do

  def error_results
    blank_results.merge(errors: [ { class: "MyError", message: "Oh, something went wrong" } ])
  end

  def activation_results
    blank_results.merge(hosted_schedule: hosted_schedule, active_schedule: active_schedule, new_schedule_activation: true)
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
