require 'rails_helper'
require_relative '../support/gtfs_import_helpers'

RSpec.describe GtfsImport, "#destructive?", type: :job do
  let(:source_url){ "http://www.my-site.com/gtfs-feed.zip"}
  let(:import){ GtfsImport.new(:source_url => source_url)}
  let(:destructive_job){ GtfsImport.new(:source_url => source_url, :destructive => true)}
  let(:nondestructive_job){ GtfsImport.new(:source_url => source_url, :destructive => false)}

  it "should properly indicate whether or not the :destructive option was invoked" do
    expect(import.destructive?).to eql(false)
    expect(destructive_job.destructive?).to eql(true)
    expect(nondestructive_job.destructive?).to eql(false)
  end
end

RSpec.describe GtfsImport, "#perform", type: :job do
  let(:source_url){ "http://www.my-site.com/gtfs-feed.zip"}
  let(:import){ described_class.new(:source_url => source_url) }
  let(:imported_schedule){ Schedule.where(:source_url => source_url, :published_at => last_modified_at, :etag => etag, :content_length => content_length).first }

  context "when unsuccessful due to errors ocurring after metadata extraction" do
    let!(:pre_import_active_schedule){ create(:schedule, :active) }

    #let(:error) { StandardError.new("OOPS OH NO")}
    before(:each) do
      stub_download_zip(source_url)
      allow(import).to receive(:transform_and_load).and_raise("OOPS SOME VALIDATION ERROR OR SOMETHING")
    end

    it "should posess a start_at but not an end_at" do
      begin
        import.perform
      rescue
      ensure
        expect(import.start_at).to_not be_blank
        expect(import.end_at).to be_blank
      end
    end

    it "should not de-activate the active schedule" do
      begin
        import.perform
      rescue
      ensure
        expect(pre_import_active_schedule.active?).to eql(true)
      end
    end

    it "should persist but not activate the imported schedule" do
      begin
        import.perform
      rescue
      ensure
        expect(imported_schedule).to_not be_blank
        expect(imported_schedule.active?).to eql(false)
      end
    end

    describe "mailer" do
      let(:start_at) { "2018-12-26 16:00:00 -0500" }
      let(:results) { {
        :source_url=>"http://www.my-site.com/gtfs-feed.zip",
        :destination_path=>"./tmp/google_transit.zip",
        :destructive=>false,
        :start_at=>start_at,
        :end_at=>"",
        :errors=>[ {:class=>"RuntimeError", :message=>"OOPS SOME VALIDATION ERROR OR SOMETHING"} ]
      } }
      let(:mail_options){ { error_class: "RuntimeError", error_message: "OOPS SOME VALIDATION ERROR OR SOMETHING", results: results } }

      let(:mailer) { class_double(GtfsImportMailer) }
      let(:message) { instance_double(ActionMailer::MessageDelivery) }

      before(:each) do
        Timecop.freeze( start_at )
        #allow(GtfsImportMailer).to receive(:schedule_activation_error).with(mail_options).and_return(message) # not sure why the test is passing without this line...
      end

      after { Timecop.return }

      it "should notify admins" do
        expect(GtfsImportMailer).to receive(:schedule_activation_error).with(mail_options).and_return(message)
        expect(message).to receive(:deliver_later).and_return(kind_of(ActionMailer::DeliveryJob))
        import.perform
      end
    end
  end

  context "when successful" do
    let(:imported_stop){ Stop.find_by_guid("NHV") }
    let(:imported_consolidated_stop_times){ StopTime.where(:trip_guid => "1640", :stop_guid => "NHV")} # there were originally two different stop times, the first with arrival and departure at 17:44:00, and the second with arrival and departure at 17:48:00

    before(:each) do
      stub_download_zip(source_url)
    end

    it "should posess a start_at and an end_at" do
      import.perform
      expect(import.start_at).to_not be_blank
      expect(import.end_at).to_not be_blank
    end

    it "should persist transit schedule metadata" do
      import.perform
      expect(imported_schedule).to_not be_blank
    end

    it "should persist transit schedule data" do
      import.perform
      expect(Agency.count).to eql(1)
      expect(Calendar.count).to eql(6)
      expect(CalendarDate.count).to eql(8)
      expect(Route.count).to eql(1)
      expect(Stop.count).to eql(17)
      expect(StopTime.count).to eql(120) # there are two intentionally sequential duplicates, else should expect 122
      expect(Trip.count).to eql(14)
    end

    it "should persist stop latitude and longitude to 8 decimal places" do
      import.perform
      expect(imported_stop.latitude.to_f).to eql(41.29771887)
      expect(imported_stop.longitude.to_f).to eql(-72.92673111)
    end

    it "should consolidate duplicative sequential stop times, using the earliest arrival and latest departure" do
      import.perform
      expect(imported_consolidated_stop_times.count).to eql(1)
      expect(imported_consolidated_stop_times.first.arrival_time).to eql("17:44:00")
      expect(imported_consolidated_stop_times.first.departure_time).to eql("17:48:00")
    end

    it "should mark the imported schedule as active" do
      import.perform
      expect(imported_schedule.active?).to eql(true)
    end

    describe "mailer" do
      let(:start_at) { "2018-12-26 16:00:00 -0500" }
      #let(:end_at)   { "2018-12-26 16:03:00 -0500" }

      let(:results) { {
        :source_url=>"http://www.my-site.com/gtfs-feed.zip",
        :destination_path=>"./tmp/google_transit.zip",
        :destructive=>false,
        :start_at=> start_at,
        :end_at=> "", # still blank because the job hasn't "finished" yet. consider modifying this construction.
        :hosted_schedule=> import.hosted_schedule.serializable_hash, #import.send(:activate), # import.hosted_schedule.serializable_hash.merge(active: true), # imported_schedule,
        :errors=>[]
      } }
      let(:mail_options){ { results: results } }

      let(:mailer) { class_double(GtfsImportMailer) }
      let(:message) { instance_double(ActionMailer::MessageDelivery) }

      before(:each) do
        Timecop.freeze( start_at )
        allow(GtfsImportMailer).to receive(:schedule_report).with(mail_options).and_return(message) # not sure why the test is passing without this line...
      end

      after { Timecop.return }

      it "should send a success message" do
        expect(GtfsImportMailer).to receive(:schedule_report).with(mail_options).and_return(message)
        expect(message).to receive(:deliver_later).and_return(kind_of(ActionMailer::DeliveryJob))
        import.perform
      end
    end
  end

  context "when destructive" do
    let!(:pre_import_hosted_active_schedule){ create(:schedule, :active, {
      :published_at => headers["last-modified"].first.to_datetime,
      :content_length => headers["content-length"].first.to_i,
      :etag => headers["etag"].first.tr('"','')
    }) }
    let(:destructive_job){ GtfsImport.new(:source_url => source_url, :destructive => true)}

    before(:each) do
      stub_download_zip(source_url)
    end

    it "should posess a start_at and an end_at " do
      destructive_job.perform
      expect(destructive_job.start_at).to_not be_blank
      expect(destructive_job.end_at).to_not be_blank
    end

    it "should proceed regardless of whether or not the hosted schedule matches the active schedule" do
      expect(destructive_job).to receive(:transform_and_load)
      #expect(destructive_job.hosted_schedule).to receive(:activate!)
      destructive_job.perform
    end
  end

end
