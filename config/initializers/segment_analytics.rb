#require 'segment/analytics'

Analytics = Segment::Analytics.new({
  write_key: ENV.fetch("SEGMENT_API_KEY", "OOPS Please configure SEGMENT_API_KEY env var"),
  on_error: Proc.new { |status, msg| print msg }
})
