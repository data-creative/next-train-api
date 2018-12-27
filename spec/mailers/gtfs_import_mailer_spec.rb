require "rails_helper"

RSpec.describe GtfsImportMailer, type: :mailer do
  let(:admin_email) { ENV.fetch("ADMIN_EMAIL") }
  let(:mailer_host) { ENV.fetch("MAILER_HOST") }

  describe ".schedule_report" do

    context "activation" do
      it_behaves_like "a schedule report email" do
        include_context "schedule report email options"

        let(:message_options) { { results: activation_results } }
        let(:subject) { "GTFS Schedule Activation!" }
      end
    end

    #context "verification" do
    #  it_behaves_like "a schedule report email" do
    #    include_context "schedule report email options"
#
    #    let(:message_options) { { results: verification_results } }
    #    let(:subject) { "GTFS Schedule Verification" }
    #  end
    #end
#
    #context "failure" do
    #  it_behaves_like "a schedule report email" do
    #    include_context "schedule report email options"
#
    #    let(:message_options) { { results: error_results } }
    #    let(:subject) { "GTFS Schedule Failure" }
    #  end
    #end







    #describe "#deliver_now" do
    #  include_context "schedule report email"
    #  let(:message_options) { { results: activation_results } }
    #  let(:message) { described_class.schedule_report(message_options).deliver_now }
    #  let(:expected_text){ [
    #    subject, "Hosted schedule:", "Previously active schedule:"
    #  ] }
#
    #  it "delivers syncronously" do
    #    expect{ message }.to change{ ActionMailer::Base.deliveries.count }.by(1)
    #  end
#
    #  context "schedule activation" do
    #    let(:subject) { "GTFS Schedule Activation!" }
#
    #    it "populates message headers" do
    #      expect(message.subject).to eq(subject)
    #      expect(message.to).to eq([admin_email])
    #      expect(message.from).to eq(["application-mailer@#{mailer_host}"])
    #    end
#
    #    it "renders message body" do
    #      content = message.body.encoded
    #      expected_text.each do |txt|
    #        expect(content).to match(txt)
    #      end
    #    end
    #  end
#
    #  context "schedule verification" do
    #    let(:subject) { "GTFS Schedule Verification" }
#
    #    it "populates message headers" do
    #      expect(message.subject).to eq(subject)
    #      expect(message.to).to eq([admin_email])
    #      expect(message.from).to eq(["application-mailer@#{mailer_host}"])
    #    end
#
    #    it "renders message body" do
    #      content = message.body.encoded
    #      expected_text.each do |txt|
    #        expect(content).to match(txt)
    #      end
    #    end
    #  end
#
    #  context "schedule failure" do
    #    let(:subject) { "GTFS Schedule Failure!" }
#
    #    it "populates message headers" do
    #      expect(message.subject).to eq(subject)
    #      expect(message.to).to eq([admin_email])
    #      expect(message.from).to eq(["application-mailer@#{mailer_host}"])
    #    end
#
    #    it "renders message body" do
    #      content = message.body.encoded
    #      expected_text.each do |txt|
    #        expect(content).to match(txt)
    #      end
    #    end
    #  end
#
#
    #end
#
    #describe "#deliver_later" do
    #  let(:delivery){ described_class.schedule_report.deliver_later }
#
    #  let(:delivery_job) { {:job=>ActionMailer::DeliveryJob, :args=>[described_class.to_s, "schedule_report", "deliver_now"], :queue=>"mailers"} }
#
    #  it "enqueues a job for later" do
    #    expect { delivery }.to change { ActionMailer::DeliveryJob.queue_adapter.enqueued_jobs.count }.by(1)
    #    delivery
    #    expect(ActionMailer::DeliveryJob.queue_adapter.enqueued_jobs.first).to eql(delivery_job)
    #  end
    #end

  end

end
