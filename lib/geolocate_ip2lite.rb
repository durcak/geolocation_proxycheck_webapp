require 'ip2location_ruby'

class  GeolocateIp2lite
  def initialize
    @i2l = Ip2location.new.open("../lib/IP2LOCATION-LITE-DB5.BIN")
  end

  def geolocate_all
    users = []
    count = 0

    User.find_each do |user|
      if IPAddress.valid? user.ip 
        record = @i2l.get_all(user.ip)
        user.city = record.city.to_s
        user.latitude = record.latitude.to_f
        user.longitude = record.longitude.to_f
        user.state = record.country_long.to_s
        user.isocode = record.country_short.to_s
        users << user
        count += 1
        if count > 800
          import(users)
          users = []
          count = 0
        end
      end
    end
    #@i2l.close()
    import(users) if users.size > 0
  end

  def geolocate_one(ip)
    @i2l.get_all(ip)
  end

  private

  def import(users)
    User.ar_import users, validation: false, on_duplicate_key_update: {conflict_target: [:id], columns: [:city, :state, :latitude, :longitude, :isocode]}
  end
end