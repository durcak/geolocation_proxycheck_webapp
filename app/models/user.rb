class User < ApplicationRecord
  include SearchCop

  require 'will_paginate/array'
  require 'proxy_ip2lite'
  require 'geolocate_ip2lite'
  require 'draw_helper'

  acts_as_copy_target

  validates :ip, presence: true
  self.per_page = 1000

  search_scope :search do
    attributes :city, :state, :ip, :idecko, :isocode
  end

  search_scope :search_proxy_type do
    attributes :proxy_type
  end

  search_scope :search_proxy do
    attributes :is_proxy
  end

  def self.import(file)
    beginning = Time.now
    users = []
    count = 0
    sum = 0 
    geolocater = GeolocateIp2lite.new
    draw_helper = DrawHelper.new

    CSV.foreach(file.path, headers: true) do |row|
      user = User.new({ip: row["ip"], latitude: row["latitude"], longitude: row["longitude"],idecko: row["id"], city: row["city"], state: row["country"], isocode: row["isocode"]})
      if IPAddress.valid? user.ip 
        count += 1
        if user.latitude.blank?
          record = geolocater.geolocate_one(user.ip)
          user.city = record.city.to_s
          user.latitude = record.latitude.to_f
          user.longitude = record.longitude.to_f
          user.state = record.country_long.to_s
          user.isocode = record.country_short.to_s
        end
        users << user
      end

      draw_helper.add_point(user.latitude, user.longitude)

      if count > 800
        User.ar_import users 
        users = []
        sum += count
        count = 0
      end
    end
    User.ar_import users if users.size > 0
    sum += count
    logger.info "Data from CSV imported in: #{Time.now - beginning} seconds, one user in: #{(Time.now - beginning)/sum} seconds."
    draw_helper.save

    geolocater = nil
    draw_helper = nil

    return sum
  end

  def self.count_geolocation
    geolocater = GeolocateIp2lite.new
    geolocater.geolocate_all()
    geolocater = nil
  end

  def self.count_proxy
    proxy_checker = ProxyIp2lite.new
    proxy_checker.count_proxy()
    proxy_checker = nil
  end
end