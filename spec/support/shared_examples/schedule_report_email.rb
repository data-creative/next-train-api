#
# @example
#   it_behaves_like "a schedule report email" do
#     include_context "schedule report email options"
#     let(:message_options) { { results: activation_results } }
#     let(:subject) { "GTFS Schedule Activation!" }
#     let(:results_keys) { [ :source_url, :start_at, :end_at, :destructive, :duration_readable, :duration_seconds, :hosted_schedule, :schedule_activation ] }
#     let(:expected_text){ [
#       subject, "Source URL:",
#       "Hosted Schedule:", hosted_schedule[:etag], hosted_schedule[:published_at]
#     ] }
#   end
#
RSpec.shared_examples "a schedule report email" do
  let(:admin_email) { ENV.fetch("ADMIN_EMAIL") }
  let(:mailer_host) { ENV.fetch("MAILER_HOST") }

  let(:message) { described_class.schedule_report(message_options).deliver_now }

  describe "#deliver_now" do
    it "delivers syncronously" do
      expect{ message }.to change{ ActionMailer::Base.deliveries.count }.by(1)
    end

    it "populates message headers" do
      expect(message.subject).to eq(subject)
      expect(message.to).to eq([admin_email])
      expect(message.from).to eq(["application-mailer@#{mailer_host}"])
    end

    it "renders message body" do
      content = message.body.encoded
      expected_text.each do |txt|
        expect(content).to match(txt)
      end
    end
  end

  describe "#deliver_later" do
    let(:delivery){ described_class.schedule_report(message_options).deliver_later }

    let(:delivery_job) { {
      :job=>ActionMailer::DeliveryJob,
      :args=>[described_class.to_s, "schedule_report", "deliver_now", message_options],
      :queue=>"mailers"
    } }

    it "enqueues a job for later" do
      expect { delivery }.to change { ActionMailer::DeliveryJob.queue_adapter.enqueued_jobs.count }.by(1)
    end

    it "enqueues the right job" do
      delivery
      enqueued_job = ActionMailer::DeliveryJob.queue_adapter.enqueued_jobs.first.deep_symbolize_keys
      expect(enqueued_job[:job]).to eql(ActionMailer::DeliveryJob)
      expect(enqueued_job[:queue]).to eql("mailers")
      expect(enqueued_job[:args][0]).to eql(described_class.to_s)
      expect(enqueued_job[:args][1]).to eql("schedule_report")
      expect(enqueued_job[:args][2]).to eql("deliver_now")
      expect(enqueued_job[:args][3][:results].keys - [:_aj_symbol_keys]).to match_array(results_keys)
    end
  end

end
