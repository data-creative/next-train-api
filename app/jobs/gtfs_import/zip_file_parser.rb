class FileParser
  def initialize(options)
    @zip_file = options[:zip_file]
    @schedule = options[:schedule]
    @logger = options[:logger]
  end

  def read_file(entry_name)
    entry = @zip_file.entries.find{|entry| entry.name == entry_name }
    return entry.get_input_stream.read
  end

  # @param [String] str An exception code (e.g. "1", "2", or "1014")
  def parse_numeric(str)
    str.to_i unless str.blank?
  end

  # @param [String] str A boolean-convertable integer (either "0" or "1")
  def parse_bool(str)
    case str; when "0"; false; when "1"; true; end
  end

  # @param [String] str A latitude or longitude decimal (e.g. "41.29771887088102" or " -72.92673110961914")
  def parse_decimal(str)
    str.strip.to_f.round(8)
  end
end
