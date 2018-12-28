class ApplicationJob < ActiveJob::Base
  attr_accessor :logger, :start_at, :end_at, :results

  def initialize(options)
    @logger = options[:logger] || Rails.logger
    @results = { errors: [] }
  end

  private

  def clock_in
    @start_at = Time.zone.now
    results[:start_at] = @start_at.to_s
    logger.info{ "JOB STARTING AT #{@start_at.to_s}" }
    @start_at
  end

  def clock_out
    @end_at = Time.zone.now
    results[:end_at] = @end_at.to_s
    results[:duration_seconds] = duration_seconds
    results[:duration_readable] = duration_readable
    logger.info{ "JOB ENDED AFTER #{duration_seconds} SECONDS" }
    @end_at
  end

  def duration_seconds
    end_at - start_at if end_at && start_at
  end

  def duration_readable
    Time.at(duration_seconds).utc.strftime("%H:%M:%S")
  end

  # @param err [Exception] like StandardError.new("OOPS")
  def handle_error(err)
    logger.error { "OOPS: #{err.class} -- #{err.message}" }
    results[:errors] << {class: err.class.to_s, message: err.message}
    err
  end

end
