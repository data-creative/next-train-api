require "rails_helper"

RSpec.describe GtfsImportMailer, type: :mailer do

  describe ".schedule_report" do
    context "activation" do
      it_behaves_like "a schedule report email" do
        include_context "schedule report email options"

        let(:message_options) { { results: activation_results } }
        let(:subject) { "GTFS Schedule Activation!" }
        let(:results_keys) { [ :source_url, :start_at, :end_at, :destructive, :duration_readable, :duration_seconds, :hosted_schedule, :schedule_activation ] }
        let(:expected_text){ [
          subject, "Source URL:",
          "Job performance", activation_results[:start_at], activation_results[:end_at], activation_results[:duration_readable],
          "Hosted Schedule:", hosted_schedule[:etag], hosted_schedule[:published_at]
        ] }
      end
    end

    context "verification" do
      it_behaves_like "a schedule report email" do
        include_context "schedule report email options"

        let(:message_options) { { results: verification_results } }
        let(:subject) { "GTFS Schedule Verification" }
        let(:results_keys) { [ :source_url, :start_at, :end_at, :destructive, :duration_readable, :duration_seconds, :hosted_schedule, :schedule_verification ] }
        let(:expected_text){ [
          subject, "Source URL:",
          "Job performance", activation_results[:start_at], activation_results[:end_at], activation_results[:duration_readable],
          "Hosted Schedule:", hosted_schedule[:etag], hosted_schedule[:published_at]
        ] }
      end
    end

    context "failure" do
      it_behaves_like "a schedule report email" do
        include_context "schedule report email options"

        let(:message_options) { { results: error_results } }
        let(:subject) { "GTFS Schedule Processing Failure" }
        let(:results_keys) { [ :source_url, :start_at, :end_at, :destructive, :duration_readable, :duration_seconds, :errors] }
        let(:expected_text){ [
          subject, "Source URL:",
          "Job performance", activation_results[:start_at], activation_results[:end_at], activation_results[:duration_readable],
          "Errors:", "MyError", "Oh, something went wrong"
        ] }
      end
    end
  end

end
