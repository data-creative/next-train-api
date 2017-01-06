require 'rails_helper'
require_relative "./../../app/jobs/gtfs_import/zip_file_parser"
require_relative '../support/gtfs_import_helpers'

RSpec.describe ZipFileParser, "#read_file" do
  let(:source_url){ "http://www.my-site.com/gtfs-feed.zip"}
  let(:import){ GtfsImport.new(:source_url => source_url) }
  let(:zip_file) {
    Zip::File.open(import.destination_path) do |zip_file|
      return zip_file
    end
  }
  let(:options){ {:zip_file => zip_file, :schedule => import.schedule} }
  let(:result){ described_class.new(options).read_file("agency.txt") }

  before(:each) do
    stub_download_zip(source_url)
    import.perform
  end

  it "should return a CSV-parsable string" do
    expect(result).to be_kind_of(String)
    expect(CSV.parse(result, :headers => true)).to be_kind_of(CSV::Table)
  end
end

RSpec.describe ZipFileParser, "#parse_numeric" do
  it "should convert a numeric string to an integer" do
    expect(described_class.new.parse_numeric "0").to eql(0)
  end

  it "should convert a blank value to nil, not zero" do
    expect(described_class.new.parse_numeric("")).to eql(nil)
  end
end

RSpec.describe ZipFileParser, "#parse_decimal" do
  it "should retain 8 decimal places" do
    expect(described_class.new.parse_decimal(" -72.92673110961914")).to eql(-72.92673111)
  end
end
