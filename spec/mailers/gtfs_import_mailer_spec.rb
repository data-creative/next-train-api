require "rails_helper"

RSpec.describe GtfsImportMailer, type: :mailer do

  describe ".schedule_report" do
    context "activation" do
      it_behaves_like "a schedule report email" do
        include_context "schedule report email options"

        let(:message_options) { { results: activation_results } }
        let(:subject) { "GTFS Schedule Activation!" }
        let(:results_keys) { [ :source_url, :start_at, :end_at, :destructive, :hosted_schedule, :schedule_activation ] }
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
        let(:results_keys) { [ :source_url, :start_at, :end_at, :destructive, :hosted_schedule, :schedule_verification ] }
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
        let(:results_keys) { [ :source_url, :start_at, :end_at, :destructive, :errors] }
        let(:expected_text){ [
          subject, "Errors:"
        ] }
      end
    end
  end

end
