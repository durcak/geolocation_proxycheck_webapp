
require 'ip2proxy_ruby'

class  ProxyIp2lite
  def initialize
    @i2p = Ip2proxy.new.open("../lib/IP2PROXY-LITE-PX2.BIN")
  end

  def count_proxy
    users = []
    count = 0
  
    User.find_each do |user|
        record = @i2p.getAll(user.ip)
        if record['is_proxy'] != 0
          user.is_proxy = true 
          user.proxy_type = record['proxy_type'].to_s
          users << user
          count += 1
        end
        if count > 1000
          puts 'nahravam 1000'
          import(users)
          users = []
          count = 0
        end
    end
    @i2p.close()
    import(users) if users.size > 0
  end

  private

  def import(users)
    User.ar_import users, validation: false, on_duplicate_key_update: {conflict_target: [:id], columns: [:is_proxy, :proxy_type]}
  end
end