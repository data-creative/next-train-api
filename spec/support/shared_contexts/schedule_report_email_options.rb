RSpec.shared_context "schedule report email options" do

  let(:blank_results) { {
    source_url: "http://www.my-site.com/gtfs-feed.zip",
    destructive: false,
    start_at: (DateTime.now - 3.minutes).to_s,
    end_at: DateTime.now.to_s
  } }

  let(:hosted_schedule) { {
    "id"=>3,
    "source_url"=>"http://www.shorelineeast.com/google_transit.zip",
    "published_at"=>"________",
    "content_length"=>12375,
    "etag"=>"9876-919fh430wmsl",
    "active"=>true,
    "created_at"=>"_____",
    "updated_at"=>""
  } }

  let(:active_schedule) { {
    "id"=>2,
    "source_url"=>"http://www.shorelineeast.com/google_transit.zip",
    "published_at"=>"________",
    "content_length"=>12375,
    "etag"=>"1234-56abcdef78khkpw",
    "active"=>false,
    "created_at"=>"_____",
    "updated_at"=>""
  } }

  let(:activation_results) {
    blank_results.merge(
      hosted_schedule: hosted_schedule,
      #active_schedule: active_schedule,
      schedule_activation: true
    )
  }

  let(:verification_results) {
    blank_results.merge(
      hosted_schedule: hosted_schedule,
      schedule_verification: true
    )
  }

  let(:error_results) {
    blank_results.merge(
      errors: [ { class: "MyError", message: "Oh, something went wrong" } ]
    )
  }

end
