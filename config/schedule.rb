require "whenever"
require 'zip'

# every "1st day in mouth" do
# end

def getGeIpDatabase
  `wget "https://www.ip2location.com/download?productcode=DB5LITEBIN&login=geolocation@europe.com&password=KzSfbeZjpp9Q" --output-document=proxy.zip`
end

def getProxyDatabase
  `wget "https://www.ip2location.com/download?productcode=PX2LITEBIN&login=geolocation@europe.com&password=KzSfbeZjpp9Q" --output-document=proxy.zip`
end

def unzipFile(fileName)
  puts File.expand_path("../" + fileName, __FILE__)
  Zip::File.open(fileName) { |zip_file|
     zip_file.each { |f|
     f_path=File.join("lib", f.name)
     # FileUtils.mkdir_p(File.dirname(f_path))
     zip_file.extract(f, f_path) unless File.exist?(f_path)
   }
  }
end

every '0 1 1 * *' do
  getGeIpDatabase
  unzipFile "geoip.zip"
end

every :day, :at => '1pm' do
  getProxyDatabase
  unzipFile 'proxy.zip'
end

