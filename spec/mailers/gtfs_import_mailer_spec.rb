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
        let(:expected_text){ [
          subject, "Hosted schedule:"
        ] }
      end
    end

    context "verification" do
      it_behaves_like "a schedule report email" do
        include_context "schedule report email options"

        let(:message_options) { { results: verification_results } }
        let(:subject) { "GTFS Schedule Verification" }
        let(:expected_text){ [
          subject, "Hosted schedule:"
        ] }
      end
    end

    context "failure" do
      it_behaves_like "a schedule report email" do
        include_context "schedule report email options"

        let(:message_options) { { results: error_results } }
        let(:subject) { "GTFS Schedule Processing Failure" }
        let(:expected_text){ [
          subject, "Errors:"
        ] }
      end
    end
  end

end
