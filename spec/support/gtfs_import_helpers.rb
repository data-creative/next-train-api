require 'zip'

module GtfsImportHelpers
  def headers
    {
      "date"=>["Fri, 30 Dec 2016 23:50:31 GMT"],
      "server"=>["Apache/2.4.10 (FreeBSD) OpenSSL/1.0.1j PHP/5.4.35"],
      "last-modified"=>["Tue, 23 Nov 2016 14:58:36 GMT"],
      "etag"=>["\"1ac9-542737db15840\""],
      "accept-ranges"=>["bytes"],
      "content-length"=>["9999"],
      "connection"=>["close"],
      "content-type"=>["application/zip"]
    }
  end

  def last_modified_at
    headers["last-modified"].first.to_datetime
  end

  def content_length
    headers["content-length"].first.to_i
  end

  def etag
    headers["etag"].first.tr('"','')
  end

  def stub_download_zip(source_url)
    stub_request(:get, source_url).with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
       to_return(:status => 200, :body => "xyz", :headers => headers)

    zip_file = Zip::File.open("./spec/data/mock_google_transit.zip")
    allow(Zip::File).to receive(:open){ |&block| block.call(zip_file) }
  end
end

RSpec.configure do |config|
  config.include GtfsImportHelpers
end
