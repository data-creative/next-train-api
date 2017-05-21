class ApplicationJob < ActiveJob::Base
  attr_reader :started_at, :ended_at, :logger

  def initialize(options)
    @logger = options[:logger] || default_logger
    @started_at = nil
    @ended_at = nil
  end

  private

  def default_logger
    Rails.env.development? ? Logger.new(STDOUT) : Rails.logger
  end

  def start
    @started_at = Time.zone.now
  end

  def finish
    @ended_at = Time.zone.now
    logger.info{ "SUCCESSFUL AFTER #{duration_seconds} SECONDS" }
  end

  def duration_seconds
    ended_at - started_at if ended_at && started_at
  end
end
