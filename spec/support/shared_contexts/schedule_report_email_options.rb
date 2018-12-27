RSpec.shared_context "schedule report email options" do

  let(:blank_results) { {
    source_url: "http://www.my-site.com/gtfs-feed.zip",
    destructive: false,
    start_at: (DateTime.now - 3.minutes).to_s,
    end_at: DateTime.now.to_s
  } }

  let(:hosted_schedule) { {
    id: 3,
    source_url: "http://www.my-site.com/gtfs-feed.zip",
    published_at: "2017-03-30 13:54:24 -0400",
    content_length: 6921,
    etag: "9876-919fh430wmsl",
    active: true,
    created_at: "2017-05-21 15:12:42 -0400",
    updated_at: "2017-05-21 15:13:00 -0400"
  } }

  let(:activation_results) {
    blank_results.merge(
      hosted_schedule: hosted_schedule,
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
      end_at: ""
      errors: [ { class: "MyError", message: "Oh, something went wrong" } ]
    )
  }

end
