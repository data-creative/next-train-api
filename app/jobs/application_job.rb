class ApplicationJob < ActiveJob::Base
  attr_accessor :started_at, :ended_at, :logger, :errors

  def initialize(options)
    @logger = options[:logger] || default_logger
    @started_at = nil
    @ended_at = nil
    @errors = []
  end

  private

  def default_logger
    Rails.env.development? ? Logger.new(STDOUT) : Rails.logger
  end

  def start
    @started_at = Time.zone.now
    logger.info{ "JOB STARTING AT #{started_at.to_s}" }
    @started_at
  end

  def finish
    @ended_at = Time.zone.now
    logger.info{ "JOB SUCCESSFUL AFTER #{duration_seconds} SECONDS" }
    @ended_at
  end

  def duration_seconds
    ended_at - started_at if ended_at && started_at
  end
end
